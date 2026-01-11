import 'package:xml/xml.dart';

import '../../core/extensions/string_extensions.dart';
import '../../domain/entities/currency_entity.dart';

class CurrencyModel extends CurrencyEntity {
  const CurrencyModel({
    required super.code,
    required super.currencyCode,
    required super.unit,
    required super.name,
    required super.currencyName,
    required super.forexBuying,
    required super.forexSelling,
    required super.banknoteBuying,
    required super.banknoteSelling,
    required super.crossRateUSD,
    required super.crossRateOther,
  });

  factory CurrencyModel.fromXml(XmlElement element) {
    return CurrencyModel(
      code: element.getAttribute('Kod') ?? '',
      currencyCode: element.getAttribute('CurrencyCode') ?? '',
      unit: (element.getAttribute('CrossOrder') ?? '0').toIntOrZero(),
      name: element.findElements('Isim').firstOrNull?.innerText ?? '',
      currencyName:
          element.findElements('CurrencyName').firstOrNull?.innerText ?? '',
      forexBuying:
          (element.findElements('ForexBuying').firstOrNull?.innerText ?? '0')
              .toDoubleOrZero(),
      forexSelling:
          (element.findElements('ForexSelling').firstOrNull?.innerText ?? '0')
              .toDoubleOrZero(),
      banknoteBuying:
          (element.findElements('BanknoteBuying').firstOrNull?.innerText ?? '0')
              .toDoubleOrZero(),
      banknoteSelling:
          (element.findElements('BanknoteSelling').firstOrNull?.innerText ??
                  '0')
              .toDoubleOrZero(),
      crossRateUSD:
          element.findElements('CrossRateUSD').firstOrNull?.innerText ?? '',
      crossRateOther:
          element.findElements('CrossRateOther').firstOrNull?.innerText ?? '',
    );
  }
}
