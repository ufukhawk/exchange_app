import 'package:equatable/equatable.dart';

/// Hata yönetimi için temel sınıf (Functional Programming pattern)
/// Either<Failure, Success> yapısında kullanılır
/// Tüm hata türleri bu sınıftan türer
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.stackTrace,
  });

  /// Kullanıcıya gösterilecek hata mesajı
  final String message;

  /// Debug için stack trace bilgisi
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, stackTrace];
}

/// Sunucu hatası (HTTP 4xx, 5xx)
/// API'den dönen hatalı yanıtlar için kullanılır
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    this.statusCode,
    super.stackTrace,
  });

  /// HTTP status kodu (404, 500, vb.)
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode, stackTrace];
}

/// İnternet bağlantısı hatası
/// SocketException durumunda kullanılır
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message =
        'No internet connection. Please check your network settings.',
    super.stackTrace,
  });
}

/// XML parse hatası
/// TCMB'den gelen XML verisi okunamadığında
class XmlParseFailure extends Failure {
  const XmlParseFailure({
    required super.message,
    this.xmlContent,
    super.stackTrace,
  });

  /// Hatalı XML içeriği (debugging için)
  final String? xmlContent;

  @override
  List<Object?> get props => [message, xmlContent, stackTrace];
}

/// Hafta sonu verisi hatası
/// TCMB hafta sonları kur yayınlamaz, otomatik Cuma'ya düşer
class WeekendDataFailure extends Failure {
  const WeekendDataFailure({
    required this.requestedDate,
    super.message =
        'No data available for weekend. Fetching data from previous Friday.',
    super.stackTrace,
  });

  /// İstenen hafta sonu tarihi
  final DateTime requestedDate;

  @override
  List<Object?> get props => [message, requestedDate, stackTrace];
}

/// Timeout hatası
/// HTTP isteği belirli sürede tamamlanmadığında
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timeout. Please try again.',
    super.stackTrace,
  });
}

/// Cache okuma/yazma hatası
/// Local storage işlemleri başarısız olduğunda
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.stackTrace,
  });
}

/// Gelecek tarih hatası
/// Henüz yayınlanmamış tarih için veri talep edildiğinde
class FutureDateFailure extends Failure {
  const FutureDateFailure({
    required super.message,
    super.stackTrace,
  });
}

/// Geçersiz tarih hatası
/// Format hatası veya mantıksal hata (örn: 32 Ocak)
class InvalidDateFailure extends Failure {
  const InvalidDateFailure({
    required super.message,
    super.stackTrace,
  });
}
