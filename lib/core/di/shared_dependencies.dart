import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SharedDependencies {
  static SharedPreferences? _sharedPreferences;
  static http.Client? _httpClient;
  static Connectivity? _connectivity;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _httpClient = http.Client();
    _connectivity = Connectivity();
  }

  /// Access to SharedPreferences instance
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw StateError(
          'SharedDependencies not initialized. Call init() first.');
    }
    return _sharedPreferences!;
  }

  /// Access to HTTP client instance
  static http.Client get httpClient {
    if (_httpClient == null) {
      throw StateError(
          'SharedDependencies not initialized. Call init() first.');
    }
    return _httpClient!;
  }

  /// Access to Connectivity instance
  static Connectivity get connectivity {
    if (_connectivity == null) {
      throw StateError(
          'SharedDependencies not initialized. Call init() first.');
    }
    return _connectivity!;
  }

  /// Cleanup resources (call on app disposal if needed)
  static void dispose() {
    _httpClient?.close();
    _httpClient = null;
    _sharedPreferences = null;
    _connectivity = null;
  }
}
