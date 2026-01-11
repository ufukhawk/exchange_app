import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/utils/tcmb_xml_parser.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_range_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_usecase.dart';
import '../network/http_client.dart';
import 'shared_dependencies.dart';

/// Dependency injection container for GetX state manager only.
/// Other state managers (MobX, BLoC) create their own dependencies directly.
class DependencyInjection {
  /// Initialize GetX-specific dependencies.
  /// Uses SharedDependencies for common platform resources.
  static void initGetX() {
    // Get shared resources
    final SharedPreferences sharedPreferences =
        SharedDependencies.sharedPreferences;
    final http.Client httpClient = SharedDependencies.httpClient;
    final Connectivity connectivity = SharedDependencies.connectivity;

    // Register in GetX DI container
    Get.lazyPut<SharedPreferences>(() => sharedPreferences);
    Get.lazyPut<http.Client>(() => httpClient);
    Get.lazyPut<Connectivity>(() => connectivity);

    Get.lazyPut<HttpClientWrapper>(
      () => HttpClientWrapper(client: Get.find<http.Client>()),
    );
    Get.lazyPut<TcmbXmlParser>(() => TcmbXmlParser());
    Get.lazyPut<SettingsLocalDatasource>(
      () => SettingsLocalDatasourceImpl(
          preferences: Get.find<SharedPreferences>()),
    );
    Get.lazyPut<ExchangeRateRemoteDatasource>(
      () => ExchangeRateRemoteDatasourceImpl(
        httpClient: Get.find<HttpClientWrapper>(),
        xmlParser: Get.find<TcmbXmlParser>(),
      ),
    );
    Get.lazyPut<SettingsRepository>(
      () => SettingsRepositoryImpl(
          localDatasource: Get.find<SettingsLocalDatasource>()),
    );
    Get.lazyPut<ExchangeRateRepository>(
      () => ExchangeRateRepositoryImpl(
          remoteDatasource: Get.find<ExchangeRateRemoteDatasource>()),
    );
    Get.lazyPut<FetchExchangeRatesUsecase>(
      () => FetchExchangeRatesUsecase(
          repository: Get.find<ExchangeRateRepository>()),
    );
    Get.lazyPut<FetchExchangeRatesRangeUsecase>(
      () => FetchExchangeRatesRangeUsecase(
          repository: Get.find<ExchangeRateRepository>()),
    );
    Get.lazyPut<ConvertCurrencyUsecase>(() => ConvertCurrencyUsecase());
  }
}
