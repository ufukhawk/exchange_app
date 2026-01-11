import '../utils/currency_formatter.dart';

/// Double tipine para formatlama extension'ları
/// Kullanım: 1234.56.toTRYString() -> "1.234,56 ₺"
extension DoubleExtensions on double {
  /// Sayıyı formatlanmış string'e çevirir (0 gösterir)
  /// Örnek: 1234.56.toFormattedString() -> "1.234,56"
  String toFormattedString({int decimalPlaces = 2}) {
    return CurrencyFormatter.formatAmount(this, decimalPlaces: decimalPlaces);
  }

  /// Para birimi formatında string'e çevirir (0 ise "-")
  /// Örnek: 0.0.toCurrencyString() -> "-"
  String toCurrencyString({int decimalPlaces = 2}) {
    return CurrencyFormatter.formatCurrency(this, decimalPlaces: decimalPlaces);
  }

  /// Döviz kuru formatında string'e çevirir (4 ondalık)
  /// Örnek: 32.1234.toRateString() -> "32,1234"
  String toRateString() {
    return CurrencyFormatter.formatRate(this);
  }

  /// TL sembolü ile formatlar
  /// Örnek: 1234.56.toTRYString() -> "1.234,56 ₺"
  String toTRYString() {
    return CurrencyFormatter.formatTRY(this);
  }

  /// Verilen sembol ile formatlar
  /// Örnek: 100.0.withSymbol("USD") -> "100,00 USD"
  String withSymbol(String symbol, {int decimalPlaces = 2}) {
    return CurrencyFormatter.formatWithSymbol(
      this,
      symbol,
      decimalPlaces: decimalPlaces,
    );
  }
}
