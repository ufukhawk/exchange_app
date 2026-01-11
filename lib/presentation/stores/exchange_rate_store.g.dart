// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExchangeRateStore on _ExchangeRateStore, Store {
  late final _$currentExchangeRateAtom =
      Atom(name: '_ExchangeRateStore.currentExchangeRate', context: context);

  @override
  ExchangeRateEntity? get currentExchangeRate {
    _$currentExchangeRateAtom.reportRead();
    return super.currentExchangeRate;
  }

  @override
  set currentExchangeRate(ExchangeRateEntity? value) {
    _$currentExchangeRateAtom.reportWrite(value, super.currentExchangeRate, () {
      super.currentExchangeRate = value;
    });
  }

  late final _$exchangeRatesAtom =
      Atom(name: '_ExchangeRateStore.exchangeRates', context: context);

  @override
  ObservableList<ExchangeRateEntity> get exchangeRates {
    _$exchangeRatesAtom.reportRead();
    return super.exchangeRates;
  }

  @override
  set exchangeRates(ObservableList<ExchangeRateEntity> value) {
    _$exchangeRatesAtom.reportWrite(value, super.exchangeRates, () {
      super.exchangeRates = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ExchangeRateStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_ExchangeRateStore.errorMessage', context: context);

  @override
  String get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$selectedDateAtom =
      Atom(name: '_ExchangeRateStore.selectedDate', context: context);

  @override
  DateTime get selectedDate {
    _$selectedDateAtom.reportRead();
    return super.selectedDate;
  }

  @override
  set selectedDate(DateTime value) {
    _$selectedDateAtom.reportWrite(value, super.selectedDate, () {
      super.selectedDate = value;
    });
  }

  late final _$convertedAmountsAtom =
      Atom(name: '_ExchangeRateStore.convertedAmounts', context: context);

  @override
  ObservableMap<String, double> get convertedAmounts {
    _$convertedAmountsAtom.reportRead();
    return super.convertedAmounts;
  }

  @override
  set convertedAmounts(ObservableMap<String, double> value) {
    _$convertedAmountsAtom.reportWrite(value, super.convertedAmounts, () {
      super.convertedAmounts = value;
    });
  }

  late final _$loadExchangeRatesAsyncAction =
      AsyncAction('_ExchangeRateStore.loadExchangeRates', context: context);

  @override
  Future<void> loadExchangeRates(DateTime date) {
    return _$loadExchangeRatesAsyncAction
        .run(() => super.loadExchangeRates(date));
  }

  late final _$loadExchangeRatesRangeAsyncAction = AsyncAction(
      '_ExchangeRateStore.loadExchangeRatesRange',
      context: context);

  @override
  Future<void> loadExchangeRatesRange(DateTime startDate, DateTime endDate) {
    return _$loadExchangeRatesRangeAsyncAction
        .run(() => super.loadExchangeRatesRange(startDate, endDate));
  }

  late final _$_ExchangeRateStoreActionController =
      ActionController(name: '_ExchangeRateStore', context: context);

  @override
  void convertCurrency(double tryAmount) {
    final ActionRunInfo _$actionInfo = _$_ExchangeRateStoreActionController
        .startAction(name: '_ExchangeRateStore.convertCurrency');
    try {
      return super.convertCurrency(tryAmount);
    } finally {
      _$_ExchangeRateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearConversion() {
    final ActionRunInfo _$actionInfo = _$_ExchangeRateStoreActionController
        .startAction(name: '_ExchangeRateStore.clearConversion');
    try {
      return super.clearConversion();
    } finally {
      _$_ExchangeRateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentExchangeRate: ${currentExchangeRate},
exchangeRates: ${exchangeRates},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
selectedDate: ${selectedDate},
convertedAmounts: ${convertedAmounts}
    ''';
  }
}
