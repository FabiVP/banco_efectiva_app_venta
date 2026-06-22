import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Cliente HTTP central para Banco Efectiva — Fuerza de Ventas.
/// Apunta al backend FastAPI en el puerto 8003.
class ApiClient {
  static ApiClient? _instance;
  final http.Client _httpClient;

  ApiClient._({http.Client? client}) : _httpClient = client ?? http.Client();

  factory ApiClient({http.Client? client}) {
    _instance ??= ApiClient._(client: client);
    return _instance!;
  }

  /// URL base del backend. En emulador Android usar 10.0.2.2.
  String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url != null && url.isNotEmpty) return url;
    // Fallback local
    return 'http://10.0.2.2:8003';
  }

  String? _bearerToken;

  void setToken(String token) => _bearerToken = token;
  void clearToken() => _bearerToken = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (_bearerToken != null) 'Authorization': 'Bearer $_bearerToken',
      };

  // ──────────────────────────────────────────────────────────────────
  // GET
  // ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[ApiClient] GET $uri');

    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 20));

    return _handleResponse(response);
  }

  // ──────────────────────────────────────────────────────────────────
  // GET que devuelve List
  // ──────────────────────────────────────────────────────────────────
  Future<List<dynamic>> getList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[ApiClient] GET-List $uri');

    final response = await _httpClient
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 20));

    final body = utf8.decode(response.bodyBytes);
    debugPrint('[ApiClient] status=${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] as List;
      }
      return [decoded];
    }
    _throwApiError(response.statusCode, body);
    return [];
  }

  // ──────────────────────────────────────────────────────────────────
  // POST
  // ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[ApiClient] POST $uri');

    final response = await _httpClient
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    return _handleResponse(response);
  }

  // ──────────────────────────────────────────────────────────────────
  // PUT / PATCH
  // ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[ApiClient] PATCH $uri');

    final response = await _httpClient
        .patch(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    return _handleResponse(response);
  }

  // ──────────────────────────────────────────────────────────────────
  // Helper
  // ──────────────────────────────────────────────────────────────────
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    debugPrint('[ApiClient] status=${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return {};
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    _throwApiError(response.statusCode, body);
    return {};
  }

  void _throwApiError(int status, String body) {
    String message = 'Error del servidor ($status)';
    try {
      final err = jsonDecode(body);
      if (err is Map) {
        message = (err['detail'] ?? err['message'] ?? err['error'] ?? message)
            .toString();
      }
    } catch (_) {}
    if (status == 401) throw UnauthorizedException(message);
    throw ApiException(status, message);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(String message) : super(401, message);
}
