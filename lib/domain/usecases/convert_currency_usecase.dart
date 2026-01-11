import '../entities/currency_entity.dart';

/// Para birimi çevirme use case
/// TRY'den diğer para birimlerine çevirme işlemi yapar
/// Pure business logic (yan etki yok, test edilebilir)
class ConvertCurrencyUsecase {
  /// TRY miktarını tüm para birimlerine çevirir
  /// [tryAmount]: Türk Lirası miktarı
  /// [currencies]: Dönüştürülecek para birimleri listesi
  /// Döner: Map<String, double> (para birimi kodu -> çevrilmiş miktar)
  /// Örnek: 1000 TRY -> {"USD": 31.25, "EUR": 28.50}
  Map<String, double> execute({
    required double tryAmount,
    required List<CurrencyEntity> currencies,
  }) {
    final results = <String, double>{};

    // Her para birimi için çevirme işlemi yap
    for (final CurrencyEntity currency in currencies) {
      // Sadece satış kuru varsa çevir (0 kontrolü)
      if (currency.forexSelling > 0) {
        final double rate = currency.forexSelling;
        // TRY / kur = yabancı para miktarı
        final double convertedAmount = tryAmount / rate;
        results[currency.currencyCode] = convertedAmount;
      }
    }

    return results;
  }
}
