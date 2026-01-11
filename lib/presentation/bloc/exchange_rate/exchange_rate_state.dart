import 'package:equatable/equatable.dart';
import '../../../domain/entities/exchange_rate_entity.dart';

/// BLoC State'leri için temel sınıf
/// State: UI'nın mevcut durumunu temsil eder
/// Her event işlendiğinde yeni bir state emit edilir
abstract class ExchangeRateState extends Equatable {
  const ExchangeRateState();

  @override
  List<Object?> get props => [];
}

/// İlk durum - Henüz hiçbir işlem yapılmadı
class ExchangeRateInitial extends ExchangeRateState {
  const ExchangeRateInitial();
}

/// Yükleniyor durumu - API isteği devam ediyor
/// UI: Loading spinner gösterilmeli
class ExchangeRateLoading extends ExchangeRateState {
  const ExchangeRateLoading();
}

/// Başarılı yükleme durumu - Döviz kuru verisi mevcut
/// UI: Kur listesini ve çeviriciyi göster
class ExchangeRateLoaded extends ExchangeRateState {
  const ExchangeRateLoaded({
    required this.exchangeRate,
    required this.selectedDate,
    this.convertedAmounts = const {},
  });

  /// Yüklenmiş döviz kuru verisi
  final ExchangeRateEntity exchangeRate;

  /// Kullanıcının seçtiği tarih
  final DateTime selectedDate;

  /// Para birimi çevirme sonuçları (opsiyonel)
  final Map<String, double> convertedAmounts;

  @override
  List<Object?> get props => [exchangeRate, selectedDate, convertedAmounts];

  /// State copy metodu
  /// Para çevirme gibi kısmi update'ler için kullanılır
  ExchangeRateLoaded copyWith({
    ExchangeRateEntity? exchangeRate,
    DateTime? selectedDate,
    Map<String, double>? convertedAmounts,
  }) {
    return ExchangeRateLoaded(
      exchangeRate: exchangeRate ?? this.exchangeRate,
      selectedDate: selectedDate ?? this.selectedDate,
      convertedAmounts: convertedAmounts ?? this.convertedAmounts,
    );
  }
}

/// Tarih aralığı yükleme başarılı durumu
/// Grafik görünümü için kullanılabilir
class ExchangeRateRangeLoaded extends ExchangeRateState {
  const ExchangeRateRangeLoaded({required this.exchangeRates});

  /// Tarih aralığındaki tüm döviz kurları
  final List<ExchangeRateEntity> exchangeRates;

  @override
  List<Object?> get props => [exchangeRates];
}

/// Hata durumu - API isteği başarısız
/// UI: Hata mesajını göster
class ExchangeRateError extends ExchangeRateState {
  const ExchangeRateError({required this.message});

  /// Kullanıcıya gösterilecek hata mesajı
  final String message;

  @override
  List<Object?> get props => [message];
}
