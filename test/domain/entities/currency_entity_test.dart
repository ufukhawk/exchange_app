import 'package:exchange_rates_app/domain/entities/currency_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/test_fixtures.dart';

void main() {
  /// Currency Entity Testleri
  /// Bu entity tek bir para biriminin tüm bilgilerini tutar (USD, EUR vb.)
  /// Equatable mixin kullanır, bu yüzden değer bazlı karşılaştırma yapar
  group('CurrencyEntity', () {
    /// TEST 1: Entity Oluşturma
    /// Tüm gerekli alanlarla entity'nin doğru oluşturulduğunu test eder
    test(
      'should be properly constructed with all required fields',
      () {
        // act
        const CurrencyEntity currency = tCurrencyEntity;

        // assert
        expect(currency.code, equals('USD'));
        expect(currency.currencyCode, equals('USD'));
        expect(currency.name, equals('AMERİKAN DOLARI'));
        expect(currency.forexSelling, equals(32.1234));
      },
    );

    /// TEST 2: Equatable Eşitlik Davranışı
    /// Aynı değerlere sahip iki entity'nin == operatörü ile eşit olduğunu doğrular
    /// Equatable sayesinde tüm field'ları tek tek karşılaştırmaya gerek kalmaz
    test(
      'should compare equal when all properties are the same (Equatable)',
      () {
        // arrange
        const currency1 = CurrencyEntity(
          code: 'USD',
          currencyCode: 'USD',
          unit: 1,
          name: 'AMERİKAN DOLARI',
          currencyName: 'US DOLLAR',
          forexBuying: 32.1000,
          forexSelling: 32.1234,
          banknoteBuying: 32.0500,
          banknoteSelling: 32.2000,
          crossRateUSD: '',
          crossRateOther: '',
        );

        const currency2 = CurrencyEntity(
          code: 'USD',
          currencyCode: 'USD',
          unit: 1,
          name: 'AMERİKAN DOLARI',
          currencyName: 'US DOLLAR',
          forexBuying: 32.1000,
          forexSelling: 32.1234,
          banknoteBuying: 32.0500,
          banknoteSelling: 32.2000,
          crossRateUSD: '',
          crossRateOther: '',
        );

        // assert
        expect(currency1, equals(currency2));
        expect(currency1.hashCode, equals(currency2.hashCode));
      },
    );

    /// TEST 3: Farklı Değerlerde Eşitsizlik
    /// Tek bir field bile farklıysa entity'lerin eşit olmaması gerekir
    /// Bu, state yönetiminde doğru rebuild'leri tetiklemek için kritik
    test(
      'should not be equal when any property is different',
      () {
        // arrange
        const CurrencyEntity currency1 = tCurrencyEntity;
        const currency2 = CurrencyEntity(
          code: 'USD',
          currencyCode: 'USD',
          unit: 1,
          name: 'AMERİKAN DOLARI',
          currencyName: 'US DOLLAR',
          forexBuying: 32.1000,
          forexSelling: 33.0, // Different
          banknoteBuying: 32.0500,
          banknoteSelling: 32.2000,
          crossRateUSD: '',
          crossRateOther: '',
        );

        // assert
        expect(currency1, isNot(equals(currency2)));
      },
    );

    /// TEST 4: Props Listesi Doğruluğu
    /// Equatable'ın karşılaştırma için kullandığı props listesinin
    /// tüm field'ları içerdiğini ve doğru sayıda olduğunu kontrol eder
    test(
      'props should return all fields for Equatable comparison',
      () {
        // arrange
        const CurrencyEntity currency = tCurrencyEntity;

        // assert
        expect(currency.props.length, equals(11));
        expect(currency.props, contains('USD'));
        expect(currency.props, contains(32.1234));
      },
    );
  });
}
