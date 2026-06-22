import '../datasources/remote/cartera_remote_datasource.dart';
import '../datasources/local/local_database.dart';
import '../../core/services/network_monitor.dart';

/// Repositorio de cartera para Banco Efectiva.
/// Implementa la lógica offline-first:
///   - Online → llama a FastAPI, guarda en SQLite local (cache)
///   - Offline → lee desde SQLite local, encola cambios pendientes
class CarteraRepository {
  final CarteraRemoteDataSource _remote;
  final LocalDatabase _local;
  final NetworkMonitor _networkMonitor;

  CarteraRepository({
    CarteraRemoteDataSource? remote,
    LocalDatabase? local,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? CarteraRemoteDataSource(),
        _local = local ?? LocalDatabase(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  /// Obtiene la cartera del día.
  /// El JWT del asesor autenticado viaja en el Header; el backend filtra por él.
  Future<List<Map<String, dynamic>>> getCarteraDiaria({
    String? asesorId,
    DateTime? fecha,
  }) async {
    if (_networkMonitor.isOnline) {
      try {
        final data = await _remote.getCarteraDiaria(fecha: fecha);
        final fechaStr =
            (fecha ?? DateTime.now()).toIso8601String().split('T').first;
        final id = asesorId ?? 'default';
        await _local.guardarCacheCartera(data, id, fechaStr);
        return data;
      } catch (e) {
        final cached = await _getCarteraOffline(asesorId ?? 'default', fecha);
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }
    return _getCarteraOffline(asesorId ?? 'default', fecha);
  }

  Future<List<Map<String, dynamic>>> _getCarteraOffline(
    String asesorId, [
    DateTime? fecha,
  ]) async {
    final fechaStr =
        (fecha ?? DateTime.now()).toIso8601String().split('T').first;
    return _local.obtenerCacheCartera(asesorId, fechaStr);
  }

  /// Registra resultado de visita.
  /// Offline: encola en SQLite para sincronizar al recuperar conexión.
  Future<void> actualizarResultadoVisita(
    String carteraId, {
    required String estadoVisita,
    String? resultado,
    String? observacion,
    double? lat,
    double? lng,
  }) async {
    if (_networkMonitor.isOnline) {
      await _remote.actualizarResultadoVisita(
        carteraId,
        estadoVisita: estadoVisita,
        resultado: resultado,
        observacion: observacion,
        lat: lat,
        lng: lng,
      );
    } else {
      await _local.guardarVisitaPendiente({
        'id': carteraId,
        'cartera_id': carteraId,
        'resultado': resultado ?? estadoVisita,
        'observacion': observacion,
        'timestamp_visita': DateTime.now().toIso8601String(),
        'lat': lat,
        'lng': lng,
        'pendiente_sync': 1,
      });
    }
  }

  /// Alertas no leídas del asesor autenticado.
  Future<List<Map<String, dynamic>>> getAlertas([String? asesorId]) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getAlertas();
  }

  Future<void> marcarAlertaLeida(String alertaId) async {
    if (_networkMonitor.isOnline) {
      await _remote.marcarAlertaLeida(alertaId);
    }
  }

  Future<List<Map<String, dynamic>>> getCampanasActivas(
      [String? asesorId]) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getCampanasActivas();
  }

  /// Sincroniza visitas pendientes que quedaron en cola offline.
  Future<void> sincronizarVisitasPendientes() async {
    if (!_networkMonitor.isOnline) return;

    final pendientes = await _local.obtenerVisitasPendientes();
    for (final visita in pendientes) {
      try {
        await _remote.actualizarResultadoVisita(
          visita['cartera_id'] as String,
          estadoVisita: visita['resultado'] as String,
          observacion: visita['observacion'] as String?,
          lat: visita['lat'] as double?,
          lng: visita['lng'] as double?,
        );
        await _local.marcarVisitaSincronizada(visita['id'] as String);
      } catch (_) {
        // Reintento en el próximo ciclo de sincronización
      }
    }
  }
}
