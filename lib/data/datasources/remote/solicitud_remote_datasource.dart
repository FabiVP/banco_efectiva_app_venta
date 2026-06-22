import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de solicitudes de crédito para Banco Efectiva.
/// Reemplaza la integración anterior con SupabaseClient (Realtime, Storage).
/// La sincronización offline se gestiona vía /sync y SQLite local.
class SolicitudRemoteDataSource {
  final ApiClient _api;

  SolicitudRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Lista de solicitudes del asesor autenticado.
  Future<List<Map<String, dynamic>>> getSolicitudes() async {
    try {
      final items = await _api.getList(ApiEndpoints.solicitudes);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Solicitud] getSolicitudes error: $e');
      rethrow;
    }
  }

  /// Crea una nueva solicitud de crédito.
  /// El backend genera el número de expediente y registra en sync_outbox.
  Future<Map<String, dynamic>> crearSolicitud(
    Map<String, dynamic> solicitud,
  ) async {
    debugPrint('[Solicitud] crearSolicitud');
    return _api.post(ApiEndpoints.solicitudes, solicitud);
  }

  /// Actualiza datos de una solicitud existente.
  Future<void> actualizarSolicitud(
    String id,
    Map<String, dynamic> datos,
  ) async {
    await _api.patch(ApiEndpoints.solicitudDetalle(id), datos);
  }

  /// Obtiene el detalle completo de una solicitud con documentos adjuntos.
  Future<Map<String, dynamic>?> getSolicitud(String id) async {
    try {
      return await _api.get(ApiEndpoints.solicitudDetalle(id));
    } catch (e) {
      debugPrint('[Solicitud] getSolicitud($id) error: $e');
      return null;
    }
  }

  /// Sube metadatos de un documento asociado a una solicitud.
  /// Los archivos binarios se envían como base64 en el body.
  Future<void> subirDocumento({
    required String solicitudId,
    required String tipoDocumento,
    required String base64Data,
    String? contentType,
    int? tamanioKb,
    double? nitidezScore,
  }) async {
    await _api.post(
      '${ApiEndpoints.solicitudDetalle(solicitudId)}/documentos',
      {
        'tipo_documento': tipoDocumento,
        'archivo_base64': base64Data,
        'content_type': contentType ?? 'image/jpeg',
        'tamanio_kb': ?tamanioKb,
        'nitidez_score': ?nitidezScore,
      },
    );
  }

  /// Guarda una nota interna en la solicitud.
  Future<void> guardarNotaInterna({
    required String solicitudId,
    required String contenido,
  }) async {
    await _api.post(
      '${ApiEndpoints.solicitudDetalle(solicitudId)}/notas',
      {'contenido': contenido},
    );
  }

  /// Obtiene las notas internas de una solicitud.
  Future<List<Map<String, dynamic>>> getNotasInternas(
    String solicitudId,
  ) async {
    try {
      final items = await _api.getList(
        '${ApiEndpoints.solicitudDetalle(solicitudId)}/notas',
      );
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Solicitud] getNotasInternas($solicitudId) error: $e');
      return [];
    }
  }

  /// Transmite al core financiero una solicitud pendiente.
  Future<Map<String, dynamic>> transmitir(String solicitudId) async {
    return _api.post(
      '${ApiEndpoints.solicitudDetalle(solicitudId)}/transmitir',
      {},
    );
  }

  /// Obtiene el cronograma de pagos de una solicitud desembolsada.
  Future<List<Map<String, dynamic>>> getCronograma(String solicitudId) async {
    try {
      final items = await _api.getList(ApiEndpoints.solicitudCronograma(solicitudId));
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Solicitud] getCronograma($solicitudId) error: $e');
      return [];
    }
  }

  /// Obtiene la bitácora de cambios de estado de una solicitud.
  Future<List<Map<String, dynamic>>> getBitacora(String solicitudId) async {
    try {
      final items = await _api.getList(ApiEndpoints.solicitudBitacora(solicitudId));
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[Solicitud] getBitacora($solicitudId) error: $e');
      return [];
    }
  }
}
