import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:fpdart/src/either.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/exchange_rate_entity.dart';
import '../../../domain/usecases/convert_currency_usecase.dart';
import '../../../domain/usecases/fetch_exchange_rates_range_usecase.dart';
import '../../../domain/usecases/fetch_exchange_rates_usecase.dart';
import 'exchange_rate_event.dart';
import 'exchange_rate_state.dart';

/// Döviz Kuru BLoC (Business Logic Component)
/// Event-Driven Architecture: Event'leri dinler, işler, State emit eder
/// Dependency Injection: Constructor'da usecase'ler alınır
/// Immutable pattern: Her event yeni state oluşturur
class ExchangeRateBloc extends Bloc<ExchangeRateEvent, ExchangeRateState> {
  ExchangeRateBloc({
    required this.fetchExchangeRatesUsecase,
    required this.fetchExchangeRatesRangeUsecase,
    required this.convertCurrencyUsecase,
  }) : super(const ExchangeRateInitial()) {
    // Event handler'ları kaydet (event tipi -> handler fonksiyonu)
    on<LoadExchangeRatesEvent>(_onLoadExchangeRates);
    on<LoadExchangeRatesRangeEvent>(_onLoadExchangeRatesRange);
    on<ConvertCurrencyEvent>(_onConvertCurrency);
    on<ClearConversionEvent>(_onClearConversion);

    // Uygulama açılır açılmaz bugünün kurlarını yükle
    add(LoadExchangeRatesEvent(date: DateTime.now()));
  }

  /// UseCase'ler (Clean Architecture - Domain Layer)
  final FetchExchangeRatesUsecase fetchExchangeRatesUsecase;
  final FetchExchangeRatesRangeUsecase fetchExchangeRatesRangeUsecase;
  final ConvertCurrencyUsecase convertCurrencyUsecase;

  /// LoadExchangeRatesEvent handler
  /// 1. Loading state emit et
  /// 2. UseCase'i çağır (Either<Failure, Entity> döner)
  /// 3. fold ile sonuç işle:
  ///    - Left (Failure): Error state emit et
  ///    - Right (Entity): Loaded state emit et
  Future<void> _onLoadExchangeRates(
    LoadExchangeRatesEvent event,
    Emitter<ExchangeRateState> emit,
  ) async {
    // Loading state (UI spinner göstermek için)
    emit(const ExchangeRateLoading());

    // UseCase çağrısı (Functional Programming - Either pattern)
    final Either<Failure, ExchangeRateEntity> result =
        await fetchExchangeRatesUsecase.execute(event.date);

    // Sonuç işleme
    result.fold(
      // Hata durumu
      (failure) => emit(ExchangeRateError(message: failure.message)),
      // Başarı durumu
      (exchangeRate) => emit(ExchangeRateLoaded(
        exchangeRate: exchangeRate,
        selectedDate: event.date,
      )),
    );
  }

  /// LoadExchangeRatesRangeEvent handler
  /// Tarih aralığı için kurları getirir (grafik için kullanılabilir)
  Future<void> _onLoadExchangeRatesRange(
    LoadExchangeRatesRangeEvent event,
    Emitter<ExchangeRateState> emit,
  ) async {
    emit(const ExchangeRateLoading());
    final Either<Failure, List<ExchangeRateEntity>> result =
        await fetchExchangeRatesRangeUsecase.execute(
      event.startDate,
      event.endDate,
    );
    result.fold(
      (failure) => emit(ExchangeRateError(message: failure.message)),
      (exchangeRates) =>
          emit(ExchangeRateRangeLoaded(exchangeRates: exchangeRates)),
    );
  }

  /// ConvertCurrencyEvent handler
  /// TRY'yi diğer para birimlerine çevirir
  /// NOT: Sadece Loaded state'deyken çalışır
  void _onConvertCurrency(
    ConvertCurrencyEvent event,
    Emitter<ExchangeRateState> emit,
  ) {
    // State kontrolü: Sadece veri yüklendiyse çevir
    if (state is ExchangeRateLoaded) {
      final currentState = state as ExchangeRateLoaded;

      // UseCase ile çevirme işlemi
      final Map<String, double> convertedAmounts =
          convertCurrencyUsecase.execute(
        tryAmount: event.tryAmount,
        currencies: currentState.exchangeRate.currencies,
      );

      // Yeni state emit et (copyWith ile sadece convertedAmounts'u güncelle)
      emit(currentState.copyWith(convertedAmounts: convertedAmounts));
    }
  }

  /// ClearConversionEvent handler
  /// Çevirme sonuçlarını temizler (kullanıcı input'u sildiğinde)
  void _onClearConversion(
    ClearConversionEvent event,
    Emitter<ExchangeRateState> emit,
  ) {
    if (state is ExchangeRateLoaded) {
      final currentState = state as ExchangeRateLoaded;
      // Boş map ile yeni state
      emit(currentState.copyWith(convertedAmounts: {}));
    }
  }
}
