import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider with ChangeNotifier {
  bool _isConnected = true; // Default: Connected
  late StreamSubscription _subscription;

  InternetProvider() {
    _initConnectivity(); // ✅ Initial check
    _checkInternet();
  }

  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _checkInternet() {
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Check if any network is available
    bool newStatus = results.any((result) => result != ConnectivityResult.none);

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
