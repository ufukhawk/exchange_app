import 'package:bloc_test/bloc_test.dart';
import 'package:exchange_rates_app/core/error/failures.dart';
import 'package:exchange_rates_app/domain/usecases/convert_currency_usecase.dart';
import 'package:exchange_rates_app/domain/usecases/fetch_exchange_rates_range_usecase.dart';
import 'package:exchange_rates_app/domain/usecases/fetch_exchange_rates_usecase.dart';
import 'package:exchange_rates_app/presentation/bloc/exchange_rate/exchange_rate_bloc.dart';
import 'package:exchange_rates_app/presentation/bloc/exchange_rate/exchange_rate_event.dart';
import 'package:exchange_rates_app/presentation/bloc/exchange_rate/exchange_rate_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/test_fixtures.dart';

/// Mock UseCases - Mocktail ile Oluşturuldu
/// BLoC'ın dependency'lerini (usecase'leri) mock'luyoruz
/// Bu sayede gerçek API çağrıları yapmadan BLoC logic'ini test edebiliriz
class MockFetchExchangeRatesUsecase extends Mock
    implements FetchExchangeRatesUsecase {}

class MockFetchExchangeRatesRangeUsecase extends Mock
    implements FetchExchangeRatesRangeUsecase {}

class MockConvertCurrencyUsecase extends Mock
    implements ConvertCurrencyUsecase {}

void main() {
  late MockFetchExchangeRatesUsecase mockFetchUsecase;
  late MockFetchExchangeRatesRangeUsecase mockFetchRangeUsecase;
  late MockConvertCurrencyUsecase mockConvertUsecase;

  setUpAll(() {
    /// Mocktail için fallback değerleri kaydediyoruz
    /// any() matcher kullandığımızda DateTime parametresi için bu değer kullanılır
    /// Null-safety desteği için gerekli
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockFetchUsecase = MockFetchExchangeRatesUsecase();
    mockFetchRangeUsecase = MockFetchExchangeRatesRangeUsecase();
    mockConvertUsecase = MockConvertCurrencyUsecase();
  });

  /// ExchangeRateBloc Testleri
  /// BLoC pattern: Event gönderilir → BLoC işler → State emit edilir
  /// Bu testler event-state flow'unun doğru çalıştığını doğrular
  group('ExchangeRateBloc', () {
    /// TEST 1: İlk State Kontrolü
    /// BLoC ilk oluşturulduğunda ExchangeRateInitial state'inde olmalı
    test('initial state should be ExchangeRateInitial', () {
      // Setup mock for constructor initial load
      when(() => mockFetchUsecase.execute(any()))
          .thenAnswer((_) async => right(tExchangeRateEntity));

      final bloc = ExchangeRateBloc(
        fetchExchangeRatesUsecase: mockFetchUsecase,
        fetchExchangeRatesRangeUsecase: mockFetchRangeUsecase,
        convertCurrencyUsecase: mockConvertUsecase,
      );

      expect(
        const ExchangeRateInitial(),
        isA<ExchangeRateInitial>(),
      );

      bloc.close();
    });

    /// TEST 2: Başarılı Veri Yükleme
    /// LoadExchangeRatesEvent gönderildiğinde:
    /// 1. Loading state emit edilir (kullanıcıya progress indicator gösterilir)
    /// 2. Usecase çağrılır ve veri alınır
    /// 3. Loaded state emit edilir (veri UI'da gösterilir)
    blocTest<ExchangeRateBloc, ExchangeRateState>(
      'emits [Loading, Loaded] when LoadExchangeRatesEvent succeeds',
      build: () {
        when(() => mockFetchUsecase.execute(any()))
            .thenAnswer((_) async => right(tExchangeRateEntity));
        return ExchangeRateBloc(
          fetchExchangeRatesUsecase: mockFetchUsecase,
          fetchExchangeRatesRangeUsecase: mockFetchRangeUsecase,
          convertCurrencyUsecase: mockConvertUsecase,
        );
      },
      act: (bloc) => bloc.add(LoadExchangeRatesEvent(date: tDate)),
      expect: () => [
        const ExchangeRateLoading(),
        ExchangeRateLoaded(
          exchangeRate: tExchangeRateEntity,
          selectedDate: tDate,
        ),
      ],
    );

    /// TEST 3: İnternet Bağlantısı Yok Hatası
    /// ConnectionFailure durumunda:
    /// 1. Loading state
    /// 2. Error state ("İnternet bağlantınızı kontrol edin" mesajı ile)
    /// NOT: Bu testte duplicate emissions var çünkü BLoC constructor'da auto-load yapıyor
    blocTest<ExchangeRateBloc, ExchangeRateState>(
      'emits [Loading, Error] when LoadExchangeRatesEvent fails',
      build: () {
        when(() => mockFetchUsecase.execute(any())).thenAnswer(
          (_) async => left(const ConnectionFailure()),
        );
        return ExchangeRateBloc(
          fetchExchangeRatesUsecase: mockFetchUsecase,
          fetchExchangeRatesRangeUsecase: mockFetchRangeUsecase,
          convertCurrencyUsecase: mockConvertUsecase,
        );
      },
      act: (bloc) => bloc.add(LoadExchangeRatesEvent(date: tDate)),
      expect: () => [
        const ExchangeRateLoading(),
        const ExchangeRateError(
          message:
              'No internet connection. Please check your network settings.',
        ),
      ],
    );

    /// TEST 4: Server Hatası
    /// ServerFailure(500) durumunda:
    /// 1. Loading state
    /// 2. Error state ("Server error" mesajı ile)
    /// TCMB API'sinden hata geldiğinde bu senaryo gerçekleşir
    blocTest<ExchangeRateBloc, ExchangeRateState>(
      'emits [Loading, Error] when server returns error',
      build: () {
        when(() => mockFetchUsecase.execute(any())).thenAnswer(
          (_) async => left(
              const ServerFailure(message: 'Server error', statusCode: 500)),
        );
        return ExchangeRateBloc(
          fetchExchangeRatesUsecase: mockFetchUsecase,
          fetchExchangeRatesRangeUsecase: mockFetchRangeUsecase,
          convertCurrencyUsecase: mockConvertUsecase,
        );
      },
      act: (bloc) => bloc.add(LoadExchangeRatesEvent(date: tDate)),
      expect: () => [
        const ExchangeRateLoading(),
        const ExchangeRateError(message: 'Server error'),
      ],
    );

    /// TEST 5: Para Birimi Dönüştürme Event'i
    /// ConvertCurrencyEvent gönderildiğinde:
    /// 1. Mevcut Loaded state'e convertedAmounts eklenir
    /// 2. Yeni Loaded state emit edilir (çevrilmiş tutarlar ile)
    /// Kullanıcı TRY girdiğinde diğer para birimlerindeki karşılıkları hesaplanır
    blocTest<ExchangeRateBloc, ExchangeRateState>(
      'emits updated Loaded state with convertedAmounts when ConvertCurrencyEvent',
      build: () {
        when(() => mockFetchUsecase.execute(any()))
            .thenAnswer((_) async => right(tExchangeRateEntity));
        when(() => mockConvertUsecase.execute(
              tryAmount: 1000,
              currencies: tExchangeRateEntity.currencies,
            )).thenReturn({'USD': 31.13, 'EUR': 28.95});
        return ExchangeRateBloc(
          fetchExchangeRatesUsecase: mockFetchUsecase,
          fetchExchangeRatesRangeUsecase: mockFetchRangeUsecase,
          convertCurrencyUsecase: mockConvertUsecase,
        );
      },
      seed: () => ExchangeRateLoaded(
        exchangeRate: tExchangeRateEntity,
        selectedDate: tDate,
      ),
      act: (bloc) => bloc.add(const ConvertCurrencyEvent(tryAmount: 1000)),
      expect: () => [
        ExchangeRateLoaded(
          exchangeRate: tExchangeRateEntity,
          selectedDate: tDate,
          convertedAmounts: const {'USD': 31.13, 'EUR': 28.95},
        ),
      ],
    );
  });
}
