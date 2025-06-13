import 'dart:async';
import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';

class DataShared extends ChangeNotifier {
  static final instance = DataShared._internal();

  late NetworkConnectionStatus networkStatus;
  late StreamSubscription networkStream;

  DataShared._internal();

  Future<void> loadInititalData() async {
    networkStatus = await NetworkConnectionService.instance.getStatus();
    _observeNetworkConnection();
  }

  void _observeNetworkConnection() {
    networkStream = NetworkConnectionService.instance
        .observeNetworkConnectionStatus((networkStatus) {
          this.networkStatus = networkStatus;
          notifyListeners();
        });
  }
}
