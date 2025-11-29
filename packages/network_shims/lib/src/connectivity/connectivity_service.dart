/// Connectivity service abstraction
abstract class ConnectivityService {
  Future<bool> isConnected();
  Stream<bool> get onConnectivityChanged;
}
