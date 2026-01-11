import '../constants/app_constants.dart';
import 'date_formatter.dart';

class UrlBuilder {
  static String buildExchangeRateUrl(DateTime date) {
    final String monthYear = DateFormatter.formatToMonthYear(date);
    final String dateStr = DateFormatter.formatToApi(date);
    return '${AppConstants.baseUrl}/$monthYear/$dateStr.xml';
  }
}
