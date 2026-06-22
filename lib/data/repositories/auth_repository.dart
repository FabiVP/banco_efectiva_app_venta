import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/services/network_monitor.dart';

/// Repositorio de autenticación para Banco Efectiva.
/// Elimina la dependencia de Supabase AuthResponse,
/// devuelve mapas planos con el contrato del backend FastAPI.
class AuthRepository {
  final AuthRemoteDataSource _remote;
  final NetworkMonitor _networkMonitor;

  AuthRepository({
    AuthRemoteDataSource? remote,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? AuthRemoteDataSource(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  /// Autenticación de asesor.
  /// Retorna: { access_token, asesor: { id, nombre, codigo, agencia_id, rol } }
  Future<Map<String, dynamic>> login(
    String codigoEmpleado,
    String password,
  ) async {
    return _remote.login(codigoEmpleado, password);
  }

  /// Cierra la sesión limpiando el Bearer token del ApiClient.
  void logout() {
    _remote.logout();
  }

  /// Obtiene perfil del asesor autenticado.
  Future<Map<String, dynamic>?> getAsesor(String asesorId) async {
    return _remote.getAsesor(asesorId);
  }

  bool get isOnline => _networkMonitor.isOnline;
}
