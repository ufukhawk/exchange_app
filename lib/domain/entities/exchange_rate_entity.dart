import 'package:equatable/equatable.dart';
import 'currency_entity.dart';

class ExchangeRateEntity extends Equatable {
  const ExchangeRateEntity({
    required this.date,
    required this.bulletinNo,
    required this.currencies,
  });
  final DateTime date;
  final String bulletinNo;
  final List<CurrencyEntity> currencies;

  @override
  List<Object?> get props => [date, bulletinNo, currencies];
}
