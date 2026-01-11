import 'package:fpdart/fpdart.dart';

import '../../core/error/failures.dart';
import '../entities/exchange_rate_entity.dart';
import '../repositories/exchange_rate_repository.dart';

class FetchExchangeRatesRangeUsecase {
  FetchExchangeRatesRangeUsecase({required this.repository});
  final ExchangeRateRepository repository;

  Future<Either<Failure, List<ExchangeRateEntity>>> execute(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return repository.fetchExchangeRatesRange(startDate, endDate);
  }
}
