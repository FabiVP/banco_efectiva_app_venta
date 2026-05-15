import 'package:flutter/material.dart';
import '../../../data/models/oficial_model.dart';
import '../../../data/datasources/demo_data.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  String _errorMessage = '';
  Oficial? _oficialActual;
  bool _isDemoMode = false;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  Oficial? get oficialActual => _oficialActual;
  bool get isDemoMode => _isDemoMode;

  Future<bool> login(String codigo, String password) async {
    _state = AuthState.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Validación demo
    if (codigo == 'EF2024-0145' && password == '1234') {
      _oficialActual = DemoData.oficialDemo;
      _isDemoMode = false;
      _state = AuthState.success;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Código o contraseña incorrectos';
    _state = AuthState.error;
    notifyListeners();
    return false;
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
}
