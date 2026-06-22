import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de cobranza y mora para Banco Efectiva.
/// Reemplaza la integración anterior con SupabaseClient.
class CobranzaRemoteDataSource {
  final ApiClient _api;

  CobranzaRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Obtiene la cartera vencida del asesor autenticado.
  /// El backend filtra por asesor mediante el JWT y calcula días de mora.
  Future<List<Map<String, dynamic>>> getCarteraVencida() async {
    try {
      final items = await _api.getList(ApiEndpoints.cobranzaMora);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cobranza] getCarteraVencida error: $e');
      rethrow;
    }
  }

  /// Registra una acción de cobranza (llamada, visita, promesa de pago, etc).
  Future<Map<String, dynamic>> registrarAccionCobranza(
    Map<String, dynamic> accion,
  ) async {
    debugPrint('[Cobranza] registrarAccion tipo=${accion['tipo_accion']}');
    return _api.post('/cobranza/acciones', accion);
  }

  /// Obtiene el historial de acciones de cobranza de un cliente.
  Future<List<Map<String, dynamic>>> getHistorialCobranza(
    String clienteId,
  ) async {
    try {
      final items = await _api.getList(
        '/cobranza/historial?cliente_id=$clienteId',
      );
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cobranza] getHistorialCobranza($clienteId) error: $e');
      return [];
    }
  }

  /// Registra una promesa de pago del cliente.
  Future<Map<String, dynamic>> registrarPromesaPago({
    required String creditoId,
    required String clienteId,
    required DateTime fechaCompromiso,
    required double montoComprometido,
    String? observacion,
  }) async {
    return _api.post('/cobranza/promesas', {
      'credito_id': creditoId,
      'cliente_id': clienteId,
      'fecha_compromiso': fechaCompromiso.toIso8601String().split('T').first,
      'monto_comprometido': montoComprometido,
      'observacion': ?observacion,
    });
  }
}
