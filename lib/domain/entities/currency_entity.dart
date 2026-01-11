import 'package:equatable/equatable.dart';

/// Para birimi entity (Domain katmanı)
/// TCMB'den gelen bir para biriminin tüm bilgilerini tutar
/// Equatable ile karşılaştırma kolaylığı sağlar
class CurrencyEntity extends Equatable {
  const CurrencyEntity({
    required this.code,
    required this.currencyCode,
    required this.unit,
    required this.name,
    required this.currencyName,
    required this.forexBuying,
    required this.forexSelling,
    required this.banknoteBuying,
    required this.banknoteSelling,
    required this.crossRateUSD,
    required this.crossRateOther,
  });

  /// Para birimi kısa kodu (örn: "USD")
  final String code;

  /// Para birimi tam kodu (örn: "USD")
  final String currencyCode;

  /// Birim miktarı (örn: 1 USD için 1, 100 JPY için 100)
  final int unit;

  /// Türkçe adı (örn: "AMERİKAN DOLARI")
  final String name;

  /// İngilizce adı (örn: "US DOLLAR")
  final String currencyName;

  /// Döviz alış kuru
  final double forexBuying;

  /// Döviz satış kuru
  final double forexSelling;

  /// Efektif alış kuru (fiziksel para)
  final double banknoteBuying;

  /// Efektif satış kuru (fiziksel para)
  final double banknoteSelling;

  /// USD karşısındaki çapraz kur
  final String crossRateUSD;

  /// Diğer para birimine karşı çapraz kur
  final String crossRateOther;

  @override
  List<Object?> get props => [
        code,
        currencyCode,
        unit,
        name,
        currencyName,
        forexBuying,
        forexSelling,
        banknoteBuying,
        banknoteSelling,
        crossRateUSD,
        crossRateOther,
      ];
}
