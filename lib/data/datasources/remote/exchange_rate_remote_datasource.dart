import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/http_client.dart';
import '../../../core/utils/url_builder.dart';
import '../../models/exchange_rate_model.dart';
import '../../utils/tcmb_xml_parser.dart';

abstract class ExchangeRateRemoteDatasource {
  Future<Either<Failure, ExchangeRateModel>> fetchExchangeRates(DateTime date);
}

class ExchangeRateRemoteDatasourceImpl implements ExchangeRateRemoteDatasource {

  ExchangeRateRemoteDatasourceImpl({
    required this.httpClient,
    required this.xmlParser,
  });
  final HttpClientWrapper httpClient;
  final TcmbXmlParser xmlParser;

  @override
  Future<Either<Failure, ExchangeRateModel>> fetchExchangeRates(
      DateTime date) async {
    final String url = UrlBuilder.buildExchangeRateUrl(date);
    final Either<Failure, String> response = await httpClient.get(url);

    return await response.fold(
      (failure) async => left(failure),
      (xmlString) {
        /// eğer xmlString uzunluğu 10000'den büyükse, async ile parse ederiz
        if (xmlString.length > 10000) {
          return xmlParser.parseExchangeRatesAsync(xmlString);
        } else {
          return xmlParser.parseExchangeRates(xmlString);
        }
      },
    );
  }
}
