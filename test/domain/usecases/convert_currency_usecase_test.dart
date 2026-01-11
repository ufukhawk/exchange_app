import 'package:exchange_rates_app/domain/entities/currency_entity.dart';
import 'package:exchange_rates_app/domain/usecases/convert_currency_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/test_fixtures.dart';

void main() {
  late ConvertCurrencyUsecase usecase;

  setUp(() {
    usecase = ConvertCurrencyUsecase();
  });

  /// Para Birimi Dönüştürme Testleri
  /// Bu usecase TRY miktarını diğer para birimlerine çevirir (USD, EUR vb.)
  group('ConvertCurrencyUsecase', () {
    /// TEST 1: Çoklu Para Birimi Dönüşümü
    /// 1000 TRY'nin tüm para birimlerine doğru şekilde dönüştürüldüğünü test eder
    /// Formül: TRY / forexSelling = Döviz Miktarı
    test(
      'should return correct converted amounts for all currencies',
      () {
        // arrange
        const tryAmount = 1000.0;
        final List<CurrencyEntity> currencies = [
          tCurrencyEntity,
          tEurCurrencyEntity
        ];

        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: tryAmount,
          currencies: currencies,
        );

        // assert
        expect(result.length, equals(2));
        expect(result['USD'], equals(tryAmount / tCurrencyEntity.forexSelling));
        expect(
            result['EUR'], equals(tryAmount / tEurCurrencyEntity.forexSelling));
      },
    );

    /// TEST 2: Tek Para Birimi Hesaplama Doğruluğu
    /// 32123.4 TRY'nin USD'ye çevrildiğinde yaklaşık 1000 USD olduğunu doğrular
    /// Bu test matematiksel hesaplamanın doğruluğunu kontrol eder
    test(
      'should return correct converted amount for single currency',
      () {
        // arrange
        const tryAmount = 32123.4; // TRY
        final List<CurrencyEntity> currencies = [
          tCurrencyEntity
        ]; // forexSelling: 32.1234

        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: tryAmount,
          currencies: currencies,
        );

        // assert
        expect(result['USD'], closeTo(1000, 0.01)); // ~1000 USD
      },
    );

    /// TEST 3: Sıfır Kurlu Para Birimlerini Atlama
    /// forexSelling değeri 0 olan para birimleri hesaplamaya dahil edilmemeli
    /// Böylece sıfıra bölme hatasından kaçınılır ve geçersiz veriler filtrelenir
    test(
      'should skip currencies with zero forexSelling',
      () {
        // arrange
        const zeroRateCurrency = CurrencyEntity(
          code: 'XXX',
          currencyCode: 'XXX',
          unit: 1,
          name: 'Test Currency',
          currencyName: 'TEST',
          forexBuying: 0,
          forexSelling: 0, // Sıfır kur
          banknoteBuying: 0,
          banknoteSelling: 0,
          crossRateUSD: '',
          crossRateOther: '',
        );

        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: 1000,
          currencies: [zeroRateCurrency, tCurrencyEntity],
        );

        // assert - sadece USD dönmeli
        expect(result.length, equals(1));
        expect(result.containsKey('XXX'), false);
        expect(result.containsKey('USD'), true);
      },
    );

    /// TEST 4: Boş Liste Durumu
    /// Hiç para birimi yoksa boş bir map dönmeli
    /// Edge case: API'den veri gelmediğinde crash yerine boş sonuç döner
    test(
      'should return empty map when no valid currencies',
      () {
        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: 1000,
          currencies: [],
        );

        // assert
        expect(result, isEmpty);
      },
    );

    /// TEST 5: Büyük Tutarlar
    /// 1 milyon TRY gibi büyük miktarların doğru hesaplandığını test eder
    /// Overflow veya precision kaybı olmadığından emin olur
    test(
      'should handle large amounts correctly',
      () {
        // arrange
        const tryAmount = 1000000.0; // 1 milyon TRY

        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: tryAmount,
          currencies: [tCurrencyEntity],
        );

        // assert
        expect(result['USD'], greaterThan(30000)); // ~31k USD
      },
    );

    /// TEST 6: Ondalıklı Sayılar
    /// 100.50 TRY gibi ondalıklı tutarların doğru işlendiğini kontrol eder
    /// Floating point precision hatalarını yakalar
    test(
      'should handle decimal amounts correctly',
      () {
        // arrange
        const tryAmount = 100.50;

        // act
        final Map<String, double> result = usecase.execute(
          tryAmount: tryAmount,
          currencies: [tCurrencyEntity],
        );

        // assert
        expect(result['USD'], closeTo(3.13, 0.01));
      },
    );
  });
}
