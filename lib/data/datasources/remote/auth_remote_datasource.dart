import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

/// Datasource de autenticación para Banco Efectiva.
/// Conecta directamente al backend FastAPI (puerto 8003).
/// Reemplaza la integración anterior con Supabase/PostgREST.
class AuthRemoteDataSource {
  final ApiClient _api;

  AuthRemoteDataSource({ApiClient? api}) : _api = api ?? ApiClient();

  /// Inicia sesión con código de empleado y contraseña.
  /// El backend valida contra bd_core_mobile.asesores con bcrypt.
  ///
  /// Retorna el mapa con:
  ///   - access_token: JWT Bearer
  ///   - asesor: datos del asesor { id, nombre, codigo, agencia_id, ... }
  Future<Map<String, dynamic>> login(
    String codigoEmpleado,
    String password,
  ) async {
    debugPrint('[Auth] login → codigo=$codigoEmpleado');

    try {
      final response = await _api.post(
        ApiEndpoints.authLogin,
        {
          'codigo_empleado': codigoEmpleado.trim().toUpperCase(),
          'password': password,
        },
      );

      final token = response['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw const ApiException(500, 'El servidor no devolvió un token válido.');
      }

      // Inyectar token para futuras peticiones
      _api.setToken(token);

      debugPrint('[Auth] login exitoso — token recibido');
      return response;
    } on UnauthorizedException {
      throw Exception('Código o contraseña incorrectos.');
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('No se pudo conectar al servidor Efectiva. '
          'Verifica tu red y que el backend esté activo en el puerto 8003.');
    }
  }

  /// Cierra sesión: limpia el token Bearer del cliente.
  void logout() {
    _api.clearToken();
    debugPrint('[Auth] sesión cerrada');
  }

  /// Obtiene los datos del asesor autenticado por ID.
  Future<Map<String, dynamic>?> getAsesor(String asesorId) async {
    try {
      return await _api.get('${ApiEndpoints.clientes}/../asesores/$asesorId');
    } catch (e) {
      debugPrint('[Auth] getAsesor error: $e');
      return null;
    }
  }

  /// Decodifica el payload JWT sin verificar firma (solo para mostrar datos).
  static Map<String, dynamic>? decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      return jsonDecode(utf8.decode(base64Url.decode(payload)))
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
