import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:english_connect/core/core.dart';

class NetworkConnectionService {
  static NetworkConnectionService instance =
      NetworkConnectionService._internal();

  NetworkConnectionService._internal();

  Future<NetworkConnectionStatus> getStatus() async {
    List<ConnectivityResult> connectivityResults =
        await (Connectivity().checkConnectivity());
    ConnectivityResult connectivityResult =
        connectivityResults.isNotEmpty
            ? connectivityResults.first
            : ConnectivityResult.none;
    return _statusFromConnectivityResult(connectivityResult);
  }

  StreamSubscription observeNetworkConnectionStatus(
    Function(NetworkConnectionStatus) onChanged,
  ) {
    return Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> events,
    ) {
      ConnectivityResult connectivityResult =
          events.isNotEmpty ? events.first : ConnectivityResult.none;
      onChanged(_statusFromConnectivityResult(connectivityResult));
    });
  }

  NetworkConnectionStatus _statusFromConnectivityResult(
    ConnectivityResult result,
  ) {
    switch (result) {
      case ConnectivityResult.ethernet:
        return NetworkConnectionStatus.connected;

      case ConnectivityResult.wifi:
        return NetworkConnectionStatus.connected;

      case ConnectivityResult.mobile:
        return NetworkConnectionStatus.connected;

      default:
        return NetworkConnectionStatus.noConnect;
    }
  }
}
