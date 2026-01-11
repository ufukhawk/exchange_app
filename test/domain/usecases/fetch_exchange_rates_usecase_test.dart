import 'package:exchange_rates_app/core/error/failures.dart';
import 'package:exchange_rates_app/domain/entities/exchange_rate_entity.dart';
import 'package:exchange_rates_app/domain/repositories/exchange_rate_repository.dart';
import 'package:exchange_rates_app/domain/usecases/fetch_exchange_rates_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/test_fixtures.dart';

/// Mock Exchange Rate Repository
/// Mocktail kullanarak repository'nin mock versiyonunu oluşturuyoruz
/// Bu sayede gerçek API çağrıları yapmadan repository davranışını test edebiliriz
class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

void main() {
  late FetchExchangeRatesUsecase usecase;
  late MockExchangeRateRepository mockRepository;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    mockRepository = MockExchangeRateRepository();
    usecase = FetchExchangeRatesUsecase(repository: mockRepository);
  });

  group('FetchExchangeRatesUsecase', () {
    /// TEST 1: Başarılı Senaryo
    /// Repository başarılı bir şekilde veri döndüğünde,
    /// usecase'in de aynı veriyi döndürdüğünü doğrular
    test(
      'should return ExchangeRateEntity when repository call is successful',
      () async {
        // arrange
        when(() => mockRepository.fetchExchangeRates(tDate))
            .thenAnswer((_) async => right(tExchangeRateEntity));

        // act
        final Either<Failure, ExchangeRateEntity> result =
            await usecase.execute(tDate);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not be failure'),
          (entity) => expect(entity, equals(tExchangeRateEntity)),
        );
        verify(() => mockRepository.fetchExchangeRates(tDate));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    /// TEST 2: İnternet Bağlantısı Yok
    /// Cihazda internet olmadığında ConnectionFailure hatası döndüğünü test eder
    /// Bu, kullanıcıya "İnternet bağlantınızı kontrol edin" mesajı gösterilmesi için önemli
    test(
      'should return ConnectionFailure when there is no internet connection',
      () async {
        // arrange
        const failure = ConnectionFailure();
        when(() => mockRepository.fetchExchangeRates(tDate))
            .thenAnswer((_) async => left(failure));

        // act
        final Either<Failure, ExchangeRateEntity> result =
            await usecase.execute(tDate);

        // assert
        expect(result.isLeft(), true);
        verify(() => mockRepository.fetchExchangeRates(tDate));
      },
    );

    /// TEST 3: Server Hatası
    /// TCMB API'si hata döndüğünde (500, 503 vb.) ServerFailure hatası alındığını doğrular
    /// Örnek: TCMB sunucusu bakımdaysa bu senaryo gerçekleşir
    test(
      'should return ServerFailure when API returns error',
      () async {
        // arrange
        const failure = ServerFailure(message: 'Server error', statusCode: 500);
        when(() => mockRepository.fetchExchangeRates(tDate))
            .thenAnswer((_) async => left(failure));

        // act
        final Either<Failure, ExchangeRateEntity> result =
            await usecase.execute(tDate);

        // assert
        expect(result.isLeft(), true);
        verify(() => mockRepository.fetchExchangeRates(tDate));
      },
    );

    /// TEST 4: İstek Zaman Aşımı
    /// API çağrısı 30 saniye içinde tamamlanmazsa TimeoutFailure döndüğünü test eder
    /// Yavaş internet bağlantısı veya sunucu yanıt vermiyorsa bu durum oluşur
    test(
      'should return TimeoutFailure when request times out',
      () async {
        // arrange
        const failure = TimeoutFailure();
        when(() => mockRepository.fetchExchangeRates(tDate))
            .thenAnswer((_) async => left(failure));

        // act
        final Either<Failure, ExchangeRateEntity> result =
            await usecase.execute(tDate);

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<TimeoutFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    /// TEST 5: Doğru Tarih Parametresi
    /// Usecase'e verilen tarihin repository'ye aynen iletildiğini doğrular
    /// Tarih formatı veya timezone hatalarını önlemek için kritik
    test(
      'should pass the correct date to repository',
      () async {
        // arrange
        when(() => mockRepository.fetchExchangeRates(tDate))
            .thenAnswer((_) async => right(tExchangeRateEntity));

        // act
        await usecase.execute(tDate);

        // assert
        verify(() => mockRepository.fetchExchangeRates(tDate));
      },
    );
  });
}
