import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de cartera diaria para Banco Efectiva.
/// Reemplaza la integración anterior con SupabaseClient.
class CarteraRemoteDataSource {
  final ApiClient _api;

  CarteraRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Obtiene la cartera del día para el asesor autenticado.
  /// El backend filtra automáticamente por el JWT del asesor.
  Future<List<Map<String, dynamic>>> getCarteraDiaria({
    DateTime? fecha,
  }) async {
    var path = ApiEndpoints.cartera;
    if (fecha != null) {
      final fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      path += '?fecha=$fechaStr';
    }

    debugPrint('[Cartera] getCarteraDiaria → $path');
    try {
      final items = await _api.getList(path);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cartera] error: $e');
      rethrow;
    }
  }

  /// Registra el resultado de una visita al cliente.
  /// Incluye geolocalización y estado de la visita.
  Future<void> actualizarResultadoVisita(
    String carteraId, {
    required String estadoVisita,
    String? resultado,
    String? observacion,
    double? lat,
    double? lng,
  }) async {
    debugPrint('[Cartera] actualizarVisita → carteraId=$carteraId');
    try {
      await _api.post(
        ApiEndpoints.carteraVisita(carteraId),
        {
          'resultado': resultado ?? estadoVisita,
          'observacion': observacion ?? '',
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
    } catch (e) {
      debugPrint('[Cartera] actualizarVisita error: $e');
      rethrow;
    }
  }

  /// Obtiene las alertas de cartera no leídas del asesor.
  Future<List<Map<String, dynamic>>> getAlertas() async {
    debugPrint('[Cartera] getAlertas');
    try {
      final items = await _api.getList(ApiEndpoints.alertas);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cartera] getAlertas error: $e');
      return [];
    }
  }

  /// Marca una alerta como leída.
  Future<void> marcarAlertaLeida(String alertaId) async {
    try {
      await _api.post(ApiEndpoints.alertaLeida(alertaId), {});
    } catch (e) {
      debugPrint('[Cartera] marcarAlertaLeida error: $e');
    }
  }

  /// Obtiene las campañas activas asignadas al asesor.
  Future<List<Map<String, dynamic>>> getCampanasActivas() async {
    debugPrint('[Cartera] getCampanasActivas');
    try {
      final items = await _api.getList(ApiEndpoints.campanas);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cartera] getCampanasActivas error: $e');
      return [];
    }
  }
}
