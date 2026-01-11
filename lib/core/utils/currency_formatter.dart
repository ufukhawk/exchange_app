import 'package:intl/intl.dart';

/// Para birimi formatlama yardımcı sınıfı
/// Türkçe locale ile sayıları formatlar (örn: 1.234,56)
class CurrencyFormatter {
  /// 2 ondalık basamaklı Türkçe formatter (örn: 1.234,56)
  static final NumberFormat _trFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '',
    decimalDigits: 2,
  );

  /// 4 ondalık basamaklı Türkçe formatter (döviz kurları için)
  static final NumberFormat _trFormatterWithDecimals = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '',
    decimalDigits: 4,
  );

  /// Para birimi değerini formatlar
  /// [value]: Formatlanacak değer
  /// [decimalPlaces]: Ondalık basamak sayısı (varsayılan: 2)
  /// [showZero]: 0 değerini göster (false ise '-' döner)
  /// Örnek: 1234.56 -> "1.234,56"
  static String formatCurrency(
    double? value, {
    int decimalPlaces = 2,
    bool showZero = false,
  }) {
    // Null veya sıfır ise tire göster (showZero false ise)
    if (value == null || (value == 0.0 && !showZero)) {
      return '-';
    }

    // Performans için önceden tanımlı formatter'ları kullan
    if (decimalPlaces == 2) {
      return _trFormatter.format(value).trim();
    } else if (decimalPlaces == 4) {
      return _trFormatterWithDecimals.format(value).trim();
    } else {
      // Özel ondalık basamak sayısı için yeni formatter oluştur
      final customFormatter = NumberFormat.currency(
        locale: 'tr_TR',
        symbol: '',
        decimalDigits: decimalPlaces,
      );
      return customFormatter.format(value).trim();
    }
  }

  /// Miktarı formatlar (0 değerini gösterir)
  /// [value]: Formatlanacak miktar
  /// [decimalPlaces]: Ondalık basamak sayısı
  /// Örnek: 0.00 -> "0,00" (formatCurrency'den farkı: 0'ı gösterir)
  static String formatAmount(
    double value, {
    int decimalPlaces = 2,
  }) {
    return formatCurrency(value, decimalPlaces: decimalPlaces, showZero: true);
  }

  /// Para birimi sembolü ile birlikte formatlar
  /// [value]: Formatlanacak değer
  /// [symbol]: Para birimi sembolü (örn: "USD", "EUR")
  /// [decimalPlaces]: Ondalık basamak sayısı
  /// Örnek: 1234.56, "USD" -> "1.234,56 USD"
  static String formatWithSymbol(
    double? value,
    String symbol, {
    int decimalPlaces = 2,
  }) {
    final String formatted =
        formatCurrency(value, decimalPlaces: decimalPlaces);
    if (formatted == '-') {
      return '-';
    }
    return '$formatted $symbol';
  }

  /// TRY (Türk Lirası) sembolü ile formatlar
  /// Örnek: 1234.56 -> "1.234,56 ₺"
  static String formatTRY(double value) {
    return '${formatAmount(value)} ₺';
  }

  /// Döviz kuru değerini formatlar (4 ondalık basamak)
  /// Örnek: 32.1234 -> "32,1234"
  static String formatRate(double? value) {
    return formatCurrency(value, decimalPlaces: 4);
  }
}
