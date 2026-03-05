// lib/services/connection_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _checker = InternetConnectionChecker();
  
  bool _hasInternet = false;
  bool _isInitialized = false;

  // Stream to listen to connection changes
  Stream<bool> get connectionStream => _checker.onStatusChange.map(
    (status) => status == InternetConnectionStatus.connected
  );

  // Check current connection status
  Future<bool> hasInternetConnection() async {
    try {
      // First check if any network is available
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Then verify actual internet access
      return await _checker.hasConnection;
    } catch (e) {
      print('❌ Connection check error: $e');
      return false;
    }
  }

  // Initialize and start listening
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initial check
    _hasInternet = await hasInternetConnection();
    
    // Listen to changes
    _checker.onStatusChange.listen((status) {
      _hasInternet = status == InternetConnectionStatus.connected;
      print('📡 Internet connection changed: $_hasInternet');
    });
    
    _isInitialized = true;
  }

  bool get isConnected => _hasInternet;
}