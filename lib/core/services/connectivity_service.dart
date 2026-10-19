import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isOnline;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startListening() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((results) async {
      _controller.add(await _hasConnection(results));
    });
  }

  Future<bool> _hasConnection([List<ConnectivityResult>? results]) async {
    final list = results ?? await _connectivity.checkConnectivity();
    return list.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isOnline => _hasConnection();

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

/// For tests and integration scenarios.
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({bool online = true}) : _online = online;

  bool _online;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  void setOnline(bool value) {
    _online = value;
    _controller.add(_online);
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isOnline async => _online;
}
