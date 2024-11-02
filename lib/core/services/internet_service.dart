import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InternetService extends StateNotifier<bool> {
  InternetService() : super(false) {
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();

    bool hasInternet = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);

    state = hasInternet;
  }

  Future<void> refreshConnectionStatus() async {
    await _checkInternetConnection();
  }
}

final internetServiceProvider = StateNotifierProvider<InternetService, bool>((ref) {
  return InternetService();
});
