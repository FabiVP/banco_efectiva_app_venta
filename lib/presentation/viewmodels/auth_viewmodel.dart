import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/oficial_model.dart';
import '../../data/datasources/demo_data.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/api/api_client.dart';

enum AuthState { idle, loading, success, error, locked }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  Oficial? _oficialActual;
  bool _isDemoMode = false;
  int _intentosFallidos = 0;
  DateTime? _bloqueoHasta;
  Timer? _desbloquearTimer;
  int _segundosRestantes = 0;

  static const int _maxIntentos = 3;
  static const int _tiempoBloqueoSegundos = 30;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  Oficial? get oficialActual => _oficialActual;
  bool get isDemoMode => _isDemoMode;
  int get intentosFallidos => _intentosFallidos;
  bool get bloqueado => _state == AuthState.locked;
  int get segundosRestantes => _segundosRestantes;

  Future<void> cargarEstadoBloqueo() async {
    final prefs = await SharedPreferences.getInstance();
    _intentosFallidos = prefs.getInt('intentos_fallidos') ?? 0;
    final bloqueoHastaMs = prefs.getInt('bloqueo_hasta_ms');
    if (bloqueoHastaMs != null) {
      final hasta = DateTime.fromMillisecondsSinceEpoch(bloqueoHastaMs);
      if (hasta.isAfter(DateTime.now())) {
        _bloqueoHasta = hasta;
        _iniciarContador();
      } else {
        await _limpiarBloqueo(prefs);
      }
    }
    notifyListeners();
  }

  Future<bool> login(String codigo, String password) async {
    if (_bloqueoHasta != null && DateTime.now().isBefore(_bloqueoHasta!)) {
      _iniciarContador();
      return false;
    }

    _state = AuthState.loading;
    notifyListeners();

    try {
      // El repository ahora devuelve Map<String, dynamic> con access_token + asesor
      final response = await _repository.login(codigo, password);

      final token = response['access_token'] as String?;
      final asesorJson = response['asesor'] as Map<String, dynamic>?;

      if (token == null || asesorJson == null) {
        _state = AuthState.error;
        _errorMessage = 'Respuesta inválida del servidor Efectiva.';
        notifyListeners();
        return false;
      }

      // Inyectar token en el ApiClient singleton para todas las peticiones siguientes
      ApiClient().setToken(token);

      _oficialActual = Oficial.fromJson(asesorJson);

      await _limpiarBloqueo();
      _isDemoMode = false;
      _state = AuthState.success;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthViewModel.login: error — $e');
      _intentosFallidos++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('intentos_fallidos', _intentosFallidos);

      if (_intentosFallidos >= _maxIntentos) {
        _bloqueoHasta =
            DateTime.now().add(Duration(seconds: _tiempoBloqueoSegundos));
        await prefs.setInt(
            'bloqueo_hasta_ms', _bloqueoHasta!.millisecondsSinceEpoch);
        _state = AuthState.locked;
        _errorMessage =
            'Cuenta bloqueada por $_tiempoBloqueoSegundos segundos';
        _iniciarContador();
      } else {
        final raw = e.toString().replaceAll('Exception: ', '').trim();
        _errorMessage = 'Error: $raw';
        _state = AuthState.error;
      }
      notifyListeners();
      return false;
    }
  }

  void _iniciarContador() {
    _desbloquearTimer?.cancel();
    _segundosRestantes = _bloqueoHasta != null
        ? _bloqueoHasta!.difference(DateTime.now()).inSeconds
        : 0;

    if (_segundosRestantes <= 0) return;

    _desbloquearTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_bloqueoHasta == null) {
        _desbloquearTimer?.cancel();
        return;
      }
      final restantes = _bloqueoHasta!.difference(DateTime.now()).inSeconds;
      if (restantes <= 0) {
        _desbloquearTimer?.cancel();
        await _limpiarBloqueo();
        _errorMessage = '';
        _state = AuthState.idle;
        notifyListeners();
      } else {
        _segundosRestantes = restantes;
        notifyListeners();
      }
    });
  }

  Future<void> _limpiarBloqueo([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs.remove('intentos_fallidos');
    await prefs.remove('bloqueo_hasta_ms');
    _intentosFallidos = 0;
    _bloqueoHasta = null;
    _segundosRestantes = 0;
    _desbloquearTimer?.cancel();
  }

  Future<bool> loginDemo() async {
    _state = AuthState.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _oficialActual = DemoData.oficialDemo;
    _isDemoMode = true;
    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    try {
      _repository.logout();
    } catch (_) {}
    ApiClient().clearToken();
    _desbloquearTimer?.cancel();
    _oficialActual = null;
    _isDemoMode = false;
    _state = AuthState.idle;
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _desbloquearTimer?.cancel();
    super.dispose();
  }
}
