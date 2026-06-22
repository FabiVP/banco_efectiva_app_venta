import '../datasources/remote/cliente_remote_datasource.dart';
import '../datasources/local/local_database.dart';
import '../../core/services/network_monitor.dart';

class ClienteRepository {
  final ClienteRemoteDataSource _remote;
  final LocalDatabase _local;
  final NetworkMonitor _networkMonitor;

  ClienteRepository({
    ClienteRemoteDataSource? remote,
    LocalDatabase? local,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? ClienteRemoteDataSource(),
        _local = local ?? LocalDatabase(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  Future<Map<String, dynamic>?> getCliente(String id) async {
    if (_networkMonitor.isOnline) {
      try {
        final data = await _remote.getCliente(id);
        if (data != null) {
          await _local.guardarCacheClientes([data]);
        }
        return data;
      } catch (_) {
        return _getClienteOffline(id);
      }
    }
    return _getClienteOffline(id);
  }

  Future<Map<String, dynamic>?> _getClienteOffline(String id) async {
    final clientes = await _local.obtenerCacheClientes();
    final match = clientes.where((c) => c['id'] == id);
    return match.isNotEmpty ? match.first : null;
  }

  Future<Map<String, dynamic>?> getClienteByDni(String dni) async {
    if (!_networkMonitor.isOnline) return null;
    return _remote.getClienteByDni(dni);
  }

  Future<Map<String, dynamic>> crearCliente(Map<String, dynamic> cliente) async {
    return _remote.crearCliente(cliente);
  }

  Future<void> actualizarCliente(String id, Map<String, dynamic> datos) async {
    await _remote.actualizarCliente(id, datos);
  }

  Future<List<Map<String, dynamic>>> getCreditosHistoricos(String clienteId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getCreditosHistoricos(clienteId);
  }

  Future<List<Map<String, dynamic>>> getCronogramaPagos(String codCuentaCredito) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getCronogramaPagos(codCuentaCredito);
  }

  Future<Map<String, dynamic>?> getPreaprobadoVigente(String clienteId) async {
    if (!_networkMonitor.isOnline) return null;
    return _remote.getPreaprobadoVigente(clienteId);
  }

  Future<Map<String, dynamic>> consultarBuro({
    required String asesorId,
    required String dni,
    String? clienteId,
    String? solicitudId,
    String? firmaConsentimiento,
  }) async {
    return _remote.consultarBuro(
      dni: dni,
      clienteId: clienteId,
      solicitudId: solicitudId,
      firmaConsentimiento: firmaConsentimiento,
    );
  }
}
