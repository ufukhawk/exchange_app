import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:exchange_rates_app/domain/repositories/exchange_rate_repository.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock sınıfları otomatik oluşturmak için annotationlar
/// Çalıştırmak için: flutter pub run build_runner build
@GenerateMocks([
  ExchangeRateRepository,
  http.Client,
  SharedPreferences,
  Connectivity,
])
void main() {}
