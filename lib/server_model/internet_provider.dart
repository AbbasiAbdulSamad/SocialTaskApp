import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider with ChangeNotifier {
  bool _isConnected = true;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  InternetProvider() {
    _initConnectivity();
    _listenConnectivity();
  }

  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _listenConnectivity() {
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final bool newStatus =
    results.any((result) => result != ConnectivityResult.none);

    if (newStatus != _isConnected) {
      _isConnected = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
