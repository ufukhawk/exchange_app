// ignore: implementation_imports
import 'package:fpdart/src/either.dart';
import 'package:get/get.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/exchange_rate_entity.dart';
import '../../../domain/usecases/convert_currency_usecase.dart';
import '../../../domain/usecases/fetch_exchange_rates_range_usecase.dart';
import '../../../domain/usecases/fetch_exchange_rates_usecase.dart';

class ExchangeRateController extends GetxController {
  ExchangeRateController({
    required this.fetchExchangeRatesUsecase,
    required this.fetchExchangeRatesRangeUsecase,
    required this.convertCurrencyUsecase,
  });
  final FetchExchangeRatesUsecase fetchExchangeRatesUsecase;
  final FetchExchangeRatesRangeUsecase fetchExchangeRatesRangeUsecase;
  final ConvertCurrencyUsecase convertCurrencyUsecase;

  final Rx<ExchangeRateEntity?> currentExchangeRate =
      Rx<ExchangeRateEntity?>(null);
  final RxList<ExchangeRateEntity> exchangeRates = <ExchangeRateEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<String, double> convertedAmounts = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadExchangeRates(DateTime.now());
  }

  Future<void> loadExchangeRates(DateTime date) async {
    isLoading.value = true;
    errorMessage.value = '';
    final Either<Failure, ExchangeRateEntity> result =
        await fetchExchangeRatesUsecase.execute(date);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        selectedDate.value = date;
      },
      (exchangeRate) {
        currentExchangeRate.value = exchangeRate;
        // Repository'den dönen gerçek tarihi kullan (15:30 kontrolü için)
        selectedDate.value = exchangeRate.date;
      },
    );
    isLoading.value = false;
  }

  Future<void> loadExchangeRatesRange(
      DateTime startDate, DateTime endDate) async {
    isLoading.value = true;
    errorMessage.value = '';
    final Either<Failure, List<ExchangeRateEntity>> result =
        await fetchExchangeRatesRangeUsecase.execute(startDate, endDate);
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (rates) => exchangeRates.value = rates,
    );
    isLoading.value = false;
  }

  void convertCurrency(double tryAmount) {
    if (currentExchangeRate.value != null) {
      convertedAmounts.value = convertCurrencyUsecase.execute(
        tryAmount: tryAmount,
        currencies: currentExchangeRate.value!.currencies,
      );
    }
  }

  void clearConversion() {
    convertedAmounts.clear();
  }
}
