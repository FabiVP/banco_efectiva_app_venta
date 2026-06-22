import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de plan de ruta para Banco Efectiva.
/// Reemplaza la integración anterior con SupabaseClient.
class RutaRemoteDataSource {
  final ApiClient _api;

  RutaRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Obtiene la ruta del día del asesor autenticado,
  /// ordenada por prioridad y orden manual guardado.
  Future<List<Map<String, dynamic>>> getRutaDelDia({
    DateTime? fecha,
  }) async {
    var path = '${ApiEndpoints.cartera}/ruta';
    if (fecha != null) {
      final fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      path += '?fecha=$fechaStr';
    }

    debugPrint('[Ruta] getRutaDelDia → $path');
    try {
      final items = await _api.getList(path);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Ruta] getRutaDelDia error: $e');
      rethrow;
    }
  }

  /// Guarda el nuevo orden de la ruta después de drag & drop.
  Future<void> actualizarOrdenRuta(String carteraId, int orden) async {
    await _api.patch(
      ApiEndpoints.carteraVisita(carteraId).replaceAll('/visita', '/orden'),
      {'orden_manual': orden},
    );
  }

  /// Guarda múltiples reordenamientos en una sola petición (batch).
  Future<void> actualizarOrdenRutaBatch(
    List<Map<String, int>> ordenItems,
  ) async {
    await _api.post('/cartera/ruta/reordenar', {'items': ordenItems});
  }
}
