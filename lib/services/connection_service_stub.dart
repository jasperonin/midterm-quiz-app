// lib/services/connection_service_stub.dart (Web version)
// This is a stub for web platform
class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  bool _hasInternet = true;

  Stream<bool> get connectionStream => 
      Stream<bool>.periodic(const Duration(seconds: 10), (_) => true).distinct();

  Future<bool> hasInternetConnection() async => true;

  Future<void> initialize() async {
    _hasInternet = true;
    print('🌐 Running on web - connection checks disabled');
  }

  bool get isConnected => _hasInternet;
}