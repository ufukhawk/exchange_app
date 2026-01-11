import 'package:intl/intl.dart';

/// Tarih formatlama yardımcı sınıfı
/// API ve kullanıcı arayüzü için farklı tarih formatları sağlar
class DateFormatter {
  /// API'ye gönderilecek formata dönüştürür
  /// Örnek: 15.01.2024 -> "15012024"
  static String formatToApi(DateTime date) {
    return DateFormat('ddMMyyyy').format(date);
  }

  /// Ay-yıl formatına dönüştürür (TCMB klasör yapısı için)
  /// Örnek: 15.01.2024 -> "202401"
  static String formatToMonthYear(DateTime date) {
    return DateFormat('yyyyMM').format(date);
  }

  /// Kullanıcıya gösterilecek formata dönüştürür
  /// Örnek: 2024-01-15 -> "15.01.2024"
  static String formatToDisplay(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// Kısaltılmış gün adını döndürür (locale'e göre)
  /// Örnek EN: "Mon", TR: "Pzt"
  static String formatToAbbreviated(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// API'den gelen tarih string'ini DateTime'a çevirir
  /// [date]: API formatı (ddMMyyyy) örn: "15012024"
  /// Döner: DateTime(2024, 1, 15)
  static DateTime parseFromApi(String date) {
    final String day = date.substring(0, 2);
    final String month = date.substring(2, 4);
    final String year = date.substring(4, 8);
    return DateTime(int.parse(year), int.parse(month), int.parse(day));
  }
}
