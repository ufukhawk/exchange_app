import 'package:equatable/equatable.dart';

/// BLoC Event'leri için temel sınıf
/// Event-Driven Architecture: Kullanıcı aksiyonları event olarak temsil edilir
/// BLoC bu event'leri dinler ve yeni state emit eder
abstract class ExchangeRateEvent extends Equatable {
  const ExchangeRateEvent();

  @override
  List<Object?> get props => [];
}

/// Döviz kurlarını yükle event'i
/// Belirli bir tarih için TCMB kurlarını getirir
class LoadExchangeRatesEvent extends ExchangeRateEvent {
  const LoadExchangeRatesEvent({required this.date});

  /// Sorgulanacak tarih
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// Tarih aralığı için döviz kurlarını yükle event'i
/// Grafik veya tablo görünümü için kullanılabilir
class LoadExchangeRatesRangeEvent extends ExchangeRateEvent {
  const LoadExchangeRatesRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  /// Başlangıç tarihi
  final DateTime startDate;

  /// Bitiş tarihi
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Para birimi çevirme event'i
/// TRY miktarını diğer para birimlerine çevirir
class ConvertCurrencyEvent extends ExchangeRateEvent {
  const ConvertCurrencyEvent({required this.tryAmount});

  /// Çevrilecek Türk Lirası miktarı
  final double tryAmount;

  @override
  List<Object?> get props => [tryAmount];
}

/// Çevirme sonuçlarını temizle event'i
/// Kullanıcı input'u temizlediğinde kullanılır
class ClearConversionEvent extends ExchangeRateEvent {
  const ClearConversionEvent();
}
