import '../datasources/remote/cobranza_remote_datasource.dart';
import '../../core/services/network_monitor.dart';

class CobranzaRepository {
  final CobranzaRemoteDataSource _remote;
  final NetworkMonitor _networkMonitor;

  CobranzaRepository({
    CobranzaRemoteDataSource? remote,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? CobranzaRemoteDataSource(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  Future<List<Map<String, dynamic>>> getCarteraVencida(String asesorId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getCarteraVencida();
  }

  Future<Map<String, dynamic>> registrarAccionCobranza(Map<String, dynamic> accion) async {
    return _remote.registrarAccionCobranza(accion);
  }

  Future<List<Map<String, dynamic>>> getHistorialCobranza(String clienteId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getHistorialCobranza(clienteId);
  }
}
