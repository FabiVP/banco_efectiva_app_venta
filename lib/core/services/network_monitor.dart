import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get onStatusChanged => _controller.stream;

  Future<void> initialize() async {
    if (kIsWeb) {
      _isOnline = true;
      return;
    }
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    _isOnline = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
    _controller.add(_isOnline);
  }

  void dispose() {
    _controller.close();
  }
}
