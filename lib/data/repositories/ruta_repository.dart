import '../datasources/remote/ruta_remote_datasource.dart';
import '../../core/services/network_monitor.dart';

class RutaRepository {
  final RutaRemoteDataSource _remote;
  final NetworkMonitor _networkMonitor;

  RutaRepository({
    RutaRemoteDataSource? remote,
    NetworkMonitor? networkMonitor,
  })  : _remote = remote ?? RutaRemoteDataSource(),
        _networkMonitor = networkMonitor ?? NetworkMonitor();

  Future<List<Map<String, dynamic>>> getRutaDelDia(String asesorId) async {
    if (!_networkMonitor.isOnline) return [];
    return _remote.getRutaDelDia();
  }

  Future<void> actualizarOrdenRuta(String carteraId, int orden) async {
    if (!_networkMonitor.isOnline) return;
    await _remote.actualizarOrdenRuta(carteraId, orden);
  }
}
