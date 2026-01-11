import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// ignore: implementation_imports
import 'package:fpdart/src/either.dart';
import 'package:get/get.dart';

import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/utils/tcmb_xml_parser.dart';
import '../../domain/entities/exchange_rate_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_range_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_usecase.dart';
import '../../presentation/controllers/getx/exchange_rate_controller.dart';
import '../../presentation/controllers/getx/settings_controller.dart';
import '../../presentation/stores/exchange_rate_store.dart';
import '../../presentation/stores/settings_store.dart';
import '../constants/app_constants.dart';
import '../di/dependency_injection.dart';
import '../di/shared_dependencies.dart';
import '../error/failures.dart';
import '../network/http_client.dart';
import '../state/app_state.dart';

abstract class StateManager {
  AppState get state;
  Stream<AppState> get stateStream;

  void loadExchangeRates(DateTime date);
  void convertCurrency(double amount);
  void updateThemeMode(ThemeModeType mode);
  void updateLanguage(LanguageType lang);
  Future<void> updateStateManagement(StateManagementType type);
  Widget buildReactiveWidget(Widget Function(AppState) builder);
  void dispose();
}

class GetXStateManager extends StateManager {
  GetXStateManager() {
    // Initialize GetX dependencies
    DependencyInjection.initGetX();

    // Create controllers
    _exchangeRateController = Get.put(ExchangeRateController(
      fetchExchangeRatesUsecase: Get.find<FetchExchangeRatesUsecase>(),
      fetchExchangeRatesRangeUsecase: Get.find(),
      convertCurrencyUsecase: Get.find<ConvertCurrencyUsecase>(),
    ));
    _settingsController = Get.put(SettingsController(
      settingsRepository: Get.find(),
    ));
    _initConnectivity();
  }
  late final ExchangeRateController _exchangeRateController;
  late final SettingsController _settingsController;
  final RxBool _isConnected = true.obs;

  void _initConnectivity() {
    final Connectivity connectivity = Get.find<Connectivity>();
    connectivity.checkConnectivity().then((results) {
      _updateConnectionStatus(results);
    });
    connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results);
      }
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected.value = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  @override
  AppState get state {
    return AppState(
      isConnected: _isConnected.value,
      isLoading: _exchangeRateController.isLoading.value,
      errorMessage: _exchangeRateController.errorMessage.value,
      currentExchangeRate: _exchangeRateController.currentExchangeRate.value,
      selectedDate: _exchangeRateController.selectedDate.value,
      convertedAmounts: _exchangeRateController.convertedAmounts,
      themeMode: _settingsController.themeMode.value,
      language: _settingsController.language.value,
      stateManagement: _settingsController.stateManagement.value,
    );
  }

  @override
  Stream<AppState> get stateStream async* {
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield state;
    }
  }

  @override
  void loadExchangeRates(DateTime date) {
    _exchangeRateController.loadExchangeRates(date);
  }

  @override
  void convertCurrency(double amount) {
    _exchangeRateController.convertCurrency(amount);
  }

  @override
  void updateThemeMode(ThemeModeType mode) {
    _settingsController.updateThemeMode(mode);
  }

  @override
  void updateLanguage(LanguageType lang) {
    _settingsController.updateLanguage(lang);
  }

  @override
  Future<void> updateStateManagement(StateManagementType type) {
    return _settingsController.updateStateManagement(type);
  }

  @override
  Widget buildReactiveWidget(Widget Function(AppState) builder) {
    return Obx(() => builder(state));
  }

  @override
  void dispose() {
    Get.delete<ExchangeRateController>();
    Get.delete<SettingsController>();
  }
}

class MobXStateManager extends StateManager {
  MobXStateManager() {
    // Create dependencies directly from SharedDependencies
    final settingsRepository = SettingsRepositoryImpl(
      localDatasource: SettingsLocalDatasourceImpl(
        preferences: SharedDependencies.sharedPreferences,
      ),
    );

    final exchangeRateRepository = ExchangeRateRepositoryImpl(
      remoteDatasource: ExchangeRateRemoteDatasourceImpl(
        httpClient: HttpClientWrapper(
          client: SharedDependencies.httpClient,
        ),
        xmlParser: TcmbXmlParser(),
      ),
    );

    _exchangeRateStore = ExchangeRateStore(
      fetchExchangeRatesUsecase: FetchExchangeRatesUsecase(
        repository: exchangeRateRepository,
      ),
      fetchExchangeRatesRangeUsecase: FetchExchangeRatesRangeUsecase(
        repository: exchangeRateRepository,
      ),
      convertCurrencyUsecase: ConvertCurrencyUsecase(),
    );

    _settingsStore = SettingsStore(
      settingsRepository: settingsRepository,
    );

    _initialize();
  }

  Future<void> _initialize() async {
    // Load initial exchange rates
    loadExchangeRates(DateTime.now());
    _initConnectivity();
  }

  late final ExchangeRateStore _exchangeRateStore;
  late final SettingsStore _settingsStore;
  bool _isConnected = true;

  void _initConnectivity() {
    final Connectivity connectivity = SharedDependencies.connectivity;
    connectivity.checkConnectivity().then((results) {
      _updateConnectionStatus(results);
    });
    connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results);
      }
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  @override
  AppState get state {
    return AppState(
      isConnected: _isConnected,
      isLoading: _exchangeRateStore.isLoading,
      errorMessage: _exchangeRateStore.errorMessage,
      currentExchangeRate: _exchangeRateStore.currentExchangeRate,
      selectedDate: _exchangeRateStore.selectedDate,
      convertedAmounts:
          Map<String, double>.from(_exchangeRateStore.convertedAmounts),
      themeMode: _settingsStore.themeMode,
      language: _settingsStore.language,
      stateManagement: _settingsStore.stateManagement,
    );
  }

  @override
  Stream<AppState> get stateStream async* {
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield state;
    }
  }

  @override
  void loadExchangeRates(DateTime date) {
    _exchangeRateStore.loadExchangeRates(date);
  }

  @override
  void convertCurrency(double amount) {
    _exchangeRateStore.convertCurrency(amount);
  }

  @override
  void updateThemeMode(ThemeModeType mode) {
    _settingsStore.updateThemeMode(mode);
  }

  @override
  void updateLanguage(LanguageType lang) {
    _settingsStore.updateLanguage(lang);
  }

  @override
  Future<void> updateStateManagement(StateManagementType type) {
    return _settingsStore.updateStateManagement(type);
  }

  @override
  Widget buildReactiveWidget(Widget Function(AppState) builder) {
    return Observer(
      builder: (_) => builder(state),
    );
  }

  @override
  void dispose() {}
}

class BlocStateManager extends StateManager {
  BlocStateManager()
      : _connectivity = SharedDependencies.connectivity,
        _settingsRepository = SettingsRepositoryImpl(
          localDatasource: SettingsLocalDatasourceImpl(
            preferences: SharedDependencies.sharedPreferences,
          ),
        ),
        _fetchExchangeRatesUsecase = FetchExchangeRatesUsecase(
          repository: ExchangeRateRepositoryImpl(
            remoteDatasource: ExchangeRateRemoteDatasourceImpl(
              httpClient: HttpClientWrapper(
                client: SharedDependencies.httpClient,
              ),
              xmlParser: TcmbXmlParser(),
            ),
          ),
        ),
        _convertCurrencyUsecase = ConvertCurrencyUsecase() {
    _initialize();
  }
  final FetchExchangeRatesUsecase _fetchExchangeRatesUsecase;
  final ConvertCurrencyUsecase _convertCurrencyUsecase;
  final SettingsRepository _settingsRepository;
  final Connectivity _connectivity;

  final _stateController = StreamController<AppState>.broadcast();
  AppState _currentState = AppState();
  bool _isConnected = true;

  void _initConnectivity() {
    _connectivity.checkConnectivity().then((results) {
      _updateConnectionStatus(results);
    });
    _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
    _updateState(_currentState.copyWith(isConnected: _isConnected));
  }

  Future<void> _initialize() async {
    final ThemeModeType themeMode = await _settingsRepository.getThemeMode();
    final LanguageType language = await _settingsRepository.getLanguage();
    final StateManagementType stateManagement =
        await _settingsRepository.getStateManagement();

    _currentState = _currentState.copyWith(
      themeMode: themeMode,
      language: language,
      stateManagement: stateManagement,
    );
    _stateController.add(_currentState);

    loadExchangeRates(DateTime.now());
    _initConnectivity();
  }

  void _updateState(AppState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  @override
  AppState get state => _currentState;

  @override
  Stream<AppState> get stateStream => _stateController.stream;

  @override
  Future<void> loadExchangeRates(DateTime date) async {
    _updateState(_currentState.copyWith(
      isLoading: true,
      errorMessage: '',
    ));

    final Either<Failure, ExchangeRateEntity> result =
        await _fetchExchangeRatesUsecase.execute(date);

    result.fold(
      (failure) => _updateState(_currentState.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        selectedDate: date,
      )),
      (exchangeRate) => _updateState(_currentState.copyWith(
        isLoading: false,
        currentExchangeRate: exchangeRate,
        // Repository'den dönen gerçek tarihi kullan (15:30 kontrolü için)
        selectedDate: exchangeRate.date,
      )),
    );
  }

  @override
  void convertCurrency(double amount) {
    if (_currentState.currentExchangeRate != null) {
      final Map<String, double> result = _convertCurrencyUsecase.execute(
        tryAmount: amount,
        currencies: _currentState.currentExchangeRate!.currencies,
      );
      _updateState(_currentState.copyWith(convertedAmounts: result));
    }
  }

  @override
  Future<void> updateThemeMode(ThemeModeType mode) async {
    await _settingsRepository.saveThemeMode(mode);
    _updateState(_currentState.copyWith(themeMode: mode));
  }

  @override
  Future<void> updateLanguage(LanguageType lang) async {
    await _settingsRepository.saveLanguage(lang);
    _updateState(_currentState.copyWith(language: lang));
  }

  @override
  Future<void> updateStateManagement(StateManagementType type) async {
    await _settingsRepository.saveStateManagement(type);
    _updateState(_currentState.copyWith(stateManagement: type));
  }

  @override
  Widget buildReactiveWidget(Widget Function(AppState) builder) {
    return StreamBuilder<AppState>(
      stream: stateStream,
      initialData: state,
      builder: (context, snapshot) {
        return builder(snapshot.data ?? state);
      },
    );
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
