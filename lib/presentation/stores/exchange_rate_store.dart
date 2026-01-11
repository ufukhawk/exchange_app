// ignore: implementation_imports
import 'package:fpdart/src/either.dart';
import 'package:mobx/mobx.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/exchange_rate_entity.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_range_usecase.dart';
import '../../domain/usecases/fetch_exchange_rates_usecase.dart';

part 'exchange_rate_store.g.dart';

// ignore: library_private_types_in_public_api
class ExchangeRateStore = _ExchangeRateStore with _$ExchangeRateStore;

abstract class _ExchangeRateStore with Store {
  _ExchangeRateStore({
    required this.fetchExchangeRatesUsecase,
    required this.fetchExchangeRatesRangeUsecase,
    required this.convertCurrencyUsecase,
  }) {
    loadExchangeRates(DateTime.now());
  }
  final FetchExchangeRatesUsecase fetchExchangeRatesUsecase;
  final FetchExchangeRatesRangeUsecase fetchExchangeRatesRangeUsecase;
  final ConvertCurrencyUsecase convertCurrencyUsecase;

  @observable
  ExchangeRateEntity? currentExchangeRate;

  @observable
  ObservableList<ExchangeRateEntity> exchangeRates =
      ObservableList<ExchangeRateEntity>();

  @observable
  bool isLoading = false;

  @observable
  String errorMessage = '';

  @observable
  DateTime selectedDate = DateTime.now();

  @observable
  ObservableMap<String, double> convertedAmounts =
      ObservableMap<String, double>();

  @action
  Future<void> loadExchangeRates(DateTime date) async {
    isLoading = true;
    errorMessage = '';
    final Either<Failure, ExchangeRateEntity> result =
        await fetchExchangeRatesUsecase.execute(date);
    result.fold(
      (failure) {
        errorMessage = failure.message;
        selectedDate = date;
      },
      (exchangeRate) {
        currentExchangeRate = exchangeRate;
        // Repository'den dönen gerçek tarihi kullan (15:30 kontrolü için)
        selectedDate = exchangeRate.date;
      },
    );
    isLoading = false;
  }

  @action
  Future<void> loadExchangeRatesRange(
      DateTime startDate, DateTime endDate) async {
    isLoading = true;
    errorMessage = '';
    final Either<Failure, List<ExchangeRateEntity>> result =
        await fetchExchangeRatesRangeUsecase.execute(startDate, endDate);
    result.fold(
      (failure) => errorMessage = failure.message,
      (rates) => exchangeRates = ObservableList.of(rates),
    );
    isLoading = false;
  }

  @action
  void convertCurrency(double tryAmount) {
    if (currentExchangeRate != null) {
      convertedAmounts = ObservableMap.of(convertCurrencyUsecase.execute(
        tryAmount: tryAmount,
        currencies: currentExchangeRate!.currencies,
      ));
    }
  }

  @action
  void clearConversion() {
    convertedAmounts.clear();
  }
}
