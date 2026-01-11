import 'package:fpdart/fpdart.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/exchange_rate_entity.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/remote/exchange_rate_remote_datasource.dart';
import '../models/exchange_rate_model.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {

  ExchangeRateRepositoryImpl({required this.remoteDatasource});
  final ExchangeRateRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, ExchangeRateEntity>> fetchExchangeRates(
      DateTime date) async {
    // Gelecek tarih kontrolü
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay.isAfter(today)) {
      return left(const FutureDateFailure(
        message: 'Gelecek tarihler için kur bilgisi mevcut değildir.',
      ));
    }

    // Hafta sonu kontrolü - kullanıcıya bilgi ver
    final bool isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    // TCMB kurları her gün saat 15:30'da yayınlanır
    // Saat 15:30'dan önce ise bir önceki günün verisini göster
    final DateTime adjustedDate = _getAdjustedDateForPublicationTime(date);
    final DateTime validDate = _getValidBusinessDay(adjustedDate);

    final Either<Failure, ExchangeRateModel> result = await remoteDatasource.fetchExchangeRates(validDate);

    // Eğer hafta sonu seçildiyse, başarılı olsa bile bilgilendirme yap
    if (isWeekend && result.isRight()) {
      return result.map((model) {
        // Veriyi döndür ama hafta sonu bilgisini de ekle
        return model;
      });
    }

    return result.fold(
      (failure) => left(failure),
      (model) => right(model as ExchangeRateEntity),
    );
  }

  @override
  Future<Either<Failure, List<ExchangeRateEntity>>> fetchExchangeRatesRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<ExchangeRateEntity> rates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (_isBusinessDay(currentDate)) {
        final Either<Failure, ExchangeRateModel> result = await remoteDatasource.fetchExchangeRates(currentDate);
        result.fold(
          (failure) => null,
          (rate) => rates.add(rate),
        );
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    if (rates.isEmpty) {
      return left(
        const ServerFailure(
          message:
              'No exchange rate data available for the specified date range',
        ),
      );
    }
    return right(rates);
  }

  bool _isBusinessDay(DateTime date) {
    return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
  }

  DateTime _getValidBusinessDay(DateTime date) {
    if (_isBusinessDay(date)) {
      return date;
    }
    if (date.weekday == DateTime.saturday) {
      return date.subtract(const Duration(days: 1));
    }
    if (date.weekday == DateTime.sunday) {
      return date.subtract(const Duration(days: 2));
    }
    return date;
  }

  /// TCMB kurları her gün saat 15:30'da yayınlanır.
  /// Eğer seçilen tarih bugün ise ve saat henüz 15:30 olmadıysa,
  /// bir önceki günün verisini döndür.
  DateTime _getAdjustedDateForPublicationTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    // Eğer seçilen tarih bugün değilse, tarihi olduğu gibi döndür
    if (!selectedDay.isAtSameMomentAs(today)) {
      return date;
    }

    // Bugün seçilmiş, saat kontrolü yap
    // Saat 15:30'dan önce ise bir önceki günü döndür
    if (now.hour < PublicationConstants.publicationHour ||
        (now.hour == PublicationConstants.publicationHour &&
            now.minute < PublicationConstants.publicationMinute)) {
      return today.subtract(const Duration(days: 1));
    }

    // Saat 15:30'dan sonra ise bugünü döndür
    return date;
  }
}
