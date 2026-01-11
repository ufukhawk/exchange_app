import 'package:fpdart/fpdart.dart';

import '../../core/error/failures.dart';
import '../entities/exchange_rate_entity.dart';
import '../repositories/exchange_rate_repository.dart';

/// Döviz kurlarını getir use case (Business Logic)
/// Belirli bir tarih için TCMB kurlarını çeker
/// Clean Architecture: Domain katmanı (framework-agnostic)
class FetchExchangeRatesUsecase {
  FetchExchangeRatesUsecase({required this.repository});

  /// Repository interface'i (Dependency Inversion)
  final ExchangeRateRepository repository;

  /// Belirtilen tarih için döviz kurlarını getir
  /// [date]: Sorgulanacak tarih
  /// Döner: Either<Failure, ExchangeRateEntity>
  ///   - Left: Hata durumu (ConnectionFailure, ServerFailure, vb.)
  ///   - Right: Başarı durumu (döviz kuru verisi)
  Future<Either<Failure, ExchangeRateEntity>> execute(DateTime date) async {
    return repository.fetchExchangeRates(date);
  }
}
