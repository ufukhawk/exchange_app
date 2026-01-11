import 'package:xml/xml.dart';

import '../../domain/entities/exchange_rate_entity.dart';
import 'currency_model.dart';

class ExchangeRateModel extends ExchangeRateEntity {
  const ExchangeRateModel({
    required super.date,
    required super.bulletinNo,
    required super.currencies,
  });

  factory ExchangeRateModel.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final XmlElement root = document.rootElement;
    final String dateStr = root.getAttribute('Tarih') ?? '';
    final String bulletinNo = root.getAttribute('Bulten_No') ?? '';
    final List<String> dateParts = dateStr.split('.');
    final date = DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
    );
    final List<CurrencyModel> currencies = root
        .findElements('Currency')
        .map((element) => CurrencyModel.fromXml(element))
        .toList();
    return ExchangeRateModel(
      date: date,
      bulletinNo: bulletinNo,
      currencies: currencies,
    );
  }
}
