import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de ficha de cliente (360°) para Banco Efectiva.
/// Reemplaza la integración anterior con SupabaseClient.
class ClienteRemoteDataSource {
  final ApiClient _api;

  ClienteRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Obtiene el perfil completo del cliente: datos, créditos, oferta preaprobada.
  Future<Map<String, dynamic>?> getCliente(String id) async {
    try {
      return await _api.get(ApiEndpoints.fichaCliente(id));
    } catch (e) {
      debugPrint('[Cliente] getCliente($id) error: $e');
      return null;
    }
  }

  /// Busca un cliente por número de DNI.
  Future<Map<String, dynamic>?> getClienteByDni(String dni) async {
    try {
      final items = await _api.getList('${ApiEndpoints.clientes}?dni=$dni');
      return items.isNotEmpty ? items.first as Map<String, dynamic> : null;
    } catch (e) {
      debugPrint('[Cliente] getClienteByDni($dni) error: $e');
      return null;
    }
  }

  /// Crea un nuevo cliente en el sistema.
  Future<Map<String, dynamic>> crearCliente(
    Map<String, dynamic> cliente,
  ) async {
    return _api.post(ApiEndpoints.clientes, cliente);
  }

  /// Actualiza datos de un cliente existente.
  Future<void> actualizarCliente(
    String id,
    Map<String, dynamic> datos,
  ) async {
    await _api.patch(ApiEndpoints.fichaCliente(id), datos);
  }

  /// Obtiene los créditos históricos del cliente (desde /clientes/{id}/ficha).
  Future<List<Map<String, dynamic>>> getCreditosHistoricos(
    String clienteId,
  ) async {
    try {
      final data = await _api.get(ApiEndpoints.fichaCliente(clienteId));
      return (data['creditos'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      debugPrint('[Cliente] getCreditosHistoricos($clienteId) error: $e');
      return [];
    }
  }

  /// Obtiene el cronograma de pagos de un crédito.
  Future<List<Map<String, dynamic>>> getCronogramaPagos(
    String codCuentaCredito,
  ) async {
    try {
      final items = await _api.getList(
        '/cliente/creditos/$codCuentaCredito/cronograma',
      );
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Cliente] getCronogramaPagos error: $e');
      return [];
    }
  }

  /// Obtiene la oferta preaprobada vigente del cliente.
  Future<Map<String, dynamic>?> getPreaprobadoVigente(
    String clienteId,
  ) async {
    try {
      final data = await _api.get(ApiEndpoints.fichaCliente(clienteId));
      return data['preaprobado'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[Cliente] getPreaprobadoVigente($clienteId) error: $e');
      return null;
    }
  }

  /// Consulta el buró de crédito de un cliente por DNI.
  Future<Map<String, dynamic>> consultarBuro({
    required String dni,
    String? clienteId,
    String? solicitudId,
    String? firmaConsentimiento,
  }) async {
    return _api.post(ApiEndpoints.buroConsulta, {
      'numero_documento': dni,
      'cliente_id': ?clienteId,
      'solicitud_id': ?solicitudId,
      'firma_consentimiento_base64': ?firmaConsentimiento,
    });
  }

}
