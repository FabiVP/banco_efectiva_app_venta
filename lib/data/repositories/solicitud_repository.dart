import '../datasources/remote/solicitud_remote_datasource.dart';
import '../datasources/local/local_database.dart';
import '../../core/services/network_monitor.dart';

class SolicitudRepository {
  final SolicitudRemoteDataSource _remote;
  final LocalDatabase _local;
  final NetworkMonitor _networkMonitor;

  SolicitudRepository({
    SolicitudRemoteDataSource? remote,
    LocalDatabase? local,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? SolicitudRemoteDataSource(),
        _local = local ?? LocalDatabase(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  /// El JWT del asesor es usado por el backend para filtrar sus solicitudes.
  Future<List<Map<String, dynamic>>> getSolicitudes([String? asesorId]) async {
    if (_networkMonitor.isOnline) {
      try {
        return await _remote.getSolicitudes();
      } catch (_) {
        return [];
      }
    }
    return _local.obtenerCacheClientes();
  }

  Future<Map<String, dynamic>> crearSolicitud(Map<String, dynamic> solicitud) async {
    if (_networkMonitor.isOnline) {
      return _remote.crearSolicitud(solicitud);
    }
    await _local.guardarBorrador({
      'id': solicitud['id'],
      'cliente_id': solicitud['cliente_id'],
      'cliente_nombre': solicitud['cliente_nombre'] ?? '',
      'paso_actual': 4,
      'datos_json': solicitud.toString(),
      'monto_solicitado': solicitud['monto_solicitado'] ?? 0,
      'asesor_id': solicitud['asesor_id'],
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    return solicitud;
  }

  Future<Map<String, dynamic>?> getSolicitud(String id) async {
    if (!_networkMonitor.isOnline) return null;
    return _remote.getSolicitud(id);
  }

  Future<void> guardarBorrador(Map<String, dynamic> borrador) async {
    await _local.guardarBorrador(borrador);
  }

  Future<List<Map<String, dynamic>>> getBorradores(String asesorId) async {
    return _local.obtenerBorradores(asesorId);
  }

  Future<void> eliminarBorrador(String id) async {
    await _local.eliminarBorrador(id);
  }

  /// Sube un documento como base64 al backend FastAPI.
  Future<void> subirDocumentoBase64({
    required String solicitudId,
    required String tipoDocumento,
    required String base64Data,
    String? contentType,
    int? tamanioKb,
  }) async {
    if (_networkMonitor.isOnline) {
      await _remote.subirDocumento(
        solicitudId: solicitudId,
        tipoDocumento: tipoDocumento,
        base64Data: base64Data,
        contentType: contentType,
        tamanioKb: tamanioKb,
      );
    }
  }

  Future<void> actualizarEstado(String id, String estado) async {
    if (_networkMonitor.isOnline) {
      await _remote.actualizarSolicitud(id, {'estado': estado});
    }
  }

  Future<void> guardarNotaInterna({
    required String solicitudId,
    required String contenido,
    String? asesorId, // ignorado — el backend lo extrae del JWT
  }) async {
    await _remote.guardarNotaInterna(
      solicitudId: solicitudId,
      contenido: contenido,
    );
  }

  Future<List<Map<String, dynamic>>> getNotasInternas(String solicitudId) async {
    return _remote.getNotasInternas(solicitudId);
  }

  Future<List<Map<String, dynamic>>> getCronograma(String solicitudId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getCronograma(solicitudId);
  }

  Future<List<Map<String, dynamic>>> getBitacora(String solicitudId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getBitacora(solicitudId);
  }
}
