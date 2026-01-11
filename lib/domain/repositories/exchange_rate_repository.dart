import 'package:fpdart/fpdart.dart';

import '../../core/error/failures.dart';
import '../entities/exchange_rate_entity.dart';

abstract class ExchangeRateRepository {
  Future<Either<Failure, ExchangeRateEntity>> fetchExchangeRates(DateTime date);
  Future<Either<Failure, List<ExchangeRateEntity>>> fetchExchangeRatesRange(
    DateTime startDate,
    DateTime endDate,
  );
}
