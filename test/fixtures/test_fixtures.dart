/// Test fixtures ve helper fonksiyonlar
/// Mock data oluşturmak için kullanılır
library;

import 'package:exchange_rates_app/domain/entities/currency_entity.dart';
import 'package:exchange_rates_app/domain/entities/exchange_rate_entity.dart';

/// Test için örnek CurrencyEntity
const CurrencyEntity tCurrencyEntity = CurrencyEntity(
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

/// Test için örnek EUR currency
const CurrencyEntity tEurCurrencyEntity = CurrencyEntity(
  code: 'EUR',
  currencyCode: 'EUR',
  unit: 1,
  name: 'EURO',
  currencyName: 'EURO',
  forexBuying: 34.5000,
  forexSelling: 34.5678,
  banknoteBuying: 34.4000,
  banknoteSelling: 34.7000,
  crossRateUSD: '',
  crossRateOther: '',
);

/// Test için örnek ExchangeRateEntity
final ExchangeRateEntity tExchangeRateEntity = ExchangeRateEntity(
  date: DateTime(2026, 1, 8),
  bulletinNo: '2026/01',
  currencies: const [
    tCurrencyEntity,
    tEurCurrencyEntity,
  ],
);

/// Test için tarih
final DateTime tDate = DateTime(2026, 1, 8);

/// Test için hafta sonu tarihi
final DateTime tWeekendDate = DateTime(2026, 1, 13); // Cumartesi

/// Test için geçersiz tarih (gelecek)
final DateTime tFutureDate = DateTime(2025, 12, 31);
