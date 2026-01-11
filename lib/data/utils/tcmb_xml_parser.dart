import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xml/xml.dart';

import '../../core/error/failures.dart';
import '../models/currency_model.dart';
import '../models/exchange_rate_model.dart';

/// TCMB XML Parser
/// TCMB (Türkiye Cumhuriyet Merkez Bankası) API'sinden gelen XML verisini
/// uygulama içinde kullanılabilir Dart model nesnelerine dönüştürür.
///
/// XML Örnek Formatı:
/// ```xml
/// <Tarih_Date Tarih="15.01.2024" Bulten_No="2024/10">
///   <Currency Kod="USD" CurrencyCode="USD">
///     <Unit>1</Unit>
///     <Isim>AMERİKAN DOLARI</Isim>
///     <ForexBuying>32.1000</ForexBuying>
///     <ForexSelling>32.1234</ForexSelling>
///     ...
///   </Currency>
/// </Tarih_Date>
/// ```
class TcmbXmlParser {
  /// XML Parsing'i Isolate'da Çalıştırma (Async)
  ///
  /// compute() fonksiyonu kullanarak parsing işlemini ayrı bir isolate'te yapar.
  /// Bu sayede büyük XML dosyaları parse edilirken UI thread bloke olmaz ve
  /// uygulama smooth çalışmaya devam eder.
  ///
  /// [xmlString]: TCMB API'sinden gelen XML response (String formatında)
  /// Returns: Either.Right(ExchangeRateModel) veya Either.Left(Failure)
  Future<Either<Failure, ExchangeRateModel>> parseExchangeRatesAsync(
    String xmlString,
  ) async {
    return compute(_parseExchangeRatesIsolate, xmlString);
  }

  /// XML Parsing'i Main Thread'de Çalıştırma (Sync)
  ///
  /// Küçük XML'ler için kullanılabilir. Büyük veri için async versiyonu tercih edin.
  ///
  /// [xmlString]: TCMB API'sinden gelen XML response
  /// Returns: Either.Right(ExchangeRateModel) veya Either.Left(Failure)
  Either<Failure, ExchangeRateModel> parseExchangeRates(String xmlString) {
    return _parseExchangeRatesIsolate(xmlString);
  }
}

/// Ana XML Parse Fonksiyonu (Isolate-safe)
///
/// XML string'i parse edip ExchangeRateModel döndürür.
/// Either pattern kullanarak başarı/hata durumlarını yönetir.
///
/// Parse Adımları:
/// 1. XML document oluştur
/// 2. Root element'i bul (Tarih_Date)
/// 3. Tarih ve bülten numarasını çıkar
/// 4. Tüm Currency elementlerini parse et
/// 5. Model oluştur ve döndür
Either<Failure, ExchangeRateModel> _parseExchangeRatesIsolate(
    String xmlString) {
  try {
    /// 1. XML String'i XmlDocument nesnesine dönüştürme
    /// Eğer XML formatı bozuksa burada XmlParserException fırlatılır
    final document = XmlDocument.parse(xmlString);

    /// 2. Root element'i alma (Tarih_Date tag'i)
    /// XML'in en üst seviye elementi, tüm döviz kurlarını içerir
    final XmlElement root = document.rootElement;

    /// 3. Root attribute'larından metadata çıkarma
    /// Tarih: DD.MM.YYYY formatında (örn: "15.01.2024")
    /// Bulten_No: TCMB'nin günlük bülten numarası (örn: "2024/10")
    final String? dateStr = root.getAttribute('Tarih');
    final String? bulletinNo = root.getAttribute('Bulten_No');

    /// 4. Tarih attribute kontrolü
    /// Date olmadan kur bilgisi hangi güne ait bilemeyiz
    if (dateStr == null || dateStr.isEmpty) {
      return left(
        const XmlParseFailure(
          message: 'Date attribute (Tarih) not found in XML',
        ),
      );
    }

    /// 5. Bülten numarası kontrolü
    /// Tracking ve debugging için önemli
    if (bulletinNo == null || bulletinNo.isEmpty) {
      return left(
        const XmlParseFailure(
          message: 'Bulletin number (Bulten_No) not found in XML',
        ),
      );
    }

    /// 6. Tarih string'ini DateTime nesnesine parse etme
    /// _parseDate fonksiyonu Either döndürür, hata kontrolü yapıyoruz
    final Either<Failure, DateTime> dateParseResult = _parseDate(dateStr);
    if (dateParseResult.isLeft()) {
      return left(dateParseResult.getLeft().toNullable()!);
    }

    final DateTime date = dateParseResult.getRight().toNullable()!;

    /// 7. Tüm Currency elementlerini parse etme
    /// Her Currency elementi bir para birimini temsil eder
    final Either<Failure, List<CurrencyModel>> currenciesResult =
        _parseCurrencies(root);

    if (currenciesResult.isLeft()) {
      return left(currenciesResult.getLeft().toNullable()!);
    }

    final List<CurrencyModel> currencies =
        currenciesResult.getRight().toNullable()!;

    /// 8. Boş liste kontrolü
    /// En az bir para birimi olmalı, yoksa veri geçersizdir
    if (currencies.isEmpty) {
      return left(
        XmlParseFailure(
          message: 'No currency data found in XML',
          xmlContent: xmlString.length > 500
              ? '${xmlString.substring(0, 500)}...'
              : xmlString,
        ),
      );
    }

    /// 9. Model oluştur ve başarı durumu döndür
    /// ExchangeRateModel tüm parse edilmiş veriyi içerir
    return right(
      ExchangeRateModel(
        date: date,
        bulletinNo: bulletinNo,
        currencies: currencies,
      ),
    );
  } on XmlParserException catch (e, stackTrace) {
    /// XML Parse Hatası
    /// xml package'ı tarafından fırlatılan hata
    /// Genelde XML formatı bozuk olduğunda oluşur
    return left(
      XmlParseFailure(
        message: 'Failed to parse XML: ${e.message}',
        xmlContent: xmlString.length > 500
            ? '${xmlString.substring(0, 500)}...'
            : xmlString,
        stackTrace: stackTrace,
      ),
    );
  } catch (e, stackTrace) {
    /// Beklenmeyen Genel Hata
    /// Yukarıdaki catch bloklarına uymayan her türlü hata
    /// Örnek: int.parse hatası, null reference vb.
    return left(
      XmlParseFailure(
        message: 'Unexpected error while parsing XML: $e',
        xmlContent: xmlString.length > 500
            ? '${xmlString.substring(0, 500)}...'
            : xmlString,
        stackTrace: stackTrace,
      ),
    );
  }
}

/// Tarih String'ini DateTime Nesnesine Dönüştürme
///
/// TCMB XML'inde tarih "DD.MM.YYYY" formatındadır (örn: "15.01.2024")
/// Bu fonksiyon string'i parse edip DateTime nesnesi oluşturur.
///
/// Validasyonlar:
/// - Format uygunluğu (3 parça olmalı: gün.ay.yıl)
/// - Yıl aralığı (1900-2100)
/// - Ay aralığı (1-12)
/// - Gün aralığı (1-31)
///
/// [dateStr]: DD.MM.YYYY formatında tarih string'i
/// Returns: Either.Right(DateTime) veya Either.Left(XmlParseFailure)
Either<Failure, DateTime> _parseDate(String dateStr) {
  try {
    /// Tarih string'ini parçalara ayırma
    /// Örnek: "15.01.2024" -> ["15", "01", "2024"]
    final List<String> dateParts = dateStr.split('.');
    if (dateParts.length != 3) {
      return left(
        XmlParseFailure(
          message: 'Invalid date format: $dateStr. Expected DD.MM.YYYY',
        ),
      );
    }

    /// String parçaları int'e çevirme
    final int day = int.parse(dateParts[0]);
    final int month = int.parse(dateParts[1]);
    final int year = int.parse(dateParts[2]);

    /// Yıl Validasyonu
    /// Makul bir tarih aralığında olmalı
    if (year < 1900 || year > 2100) {
      return left(
        XmlParseFailure(
          message: 'Invalid year in date: $year',
        ),
      );
    }

    /// Ay Validasyonu
    /// 1-12 arası olmalı
    if (month < 1 || month > 12) {
      return left(
        XmlParseFailure(
          message: 'Invalid month in date: $month',
        ),
      );
    }

    /// Gün Validasyonu
    /// 1-31 arası olmalı (basit validasyon)
    if (day < 1 || day > 31) {
      return left(
        XmlParseFailure(
          message: 'Invalid day in date: $day',
        ),
      );
    }

    /// DateTime nesnesi oluştur ve döndür
    final date = DateTime(year, month, day);
    return right(date);
  } catch (e, stackTrace) {
    /// Parse hatası
    /// int.parse veya DateTime constructor hatası
    return left(
      XmlParseFailure(
        message: 'Failed to parse date: $dateStr. Error: $e',
        stackTrace: stackTrace,
      ),
    );
  }
}

/// Tüm Currency Elementlerini Parse Etme
///
/// XML'deki tüm Currency elementlerini bulup her birini CurrencyModel'e çevirir.
///
/// Fault-Tolerant Yaklaşım:
/// Bir para biriminde hata olsa bile diğerlerini parse etmeye devam eder.
/// Bu sayede tek bir bozuk veri tüm listeyi bozmaz.
///
/// [root]: Tarih_Date root elementi
/// Returns: Either.Right(List<CurrencyModel>) veya Either.Left(XmlParseFailure)
Either<Failure, List<CurrencyModel>> _parseCurrencies(XmlElement root) {
  try {
    /// Tüm Currency elementlerini bulma
    /// Her Currency elementi bir para birimini temsil eder (USD, EUR, GBP vb.)
    /// XML'de genellikle 15-20 farklı para birimi bulunur
    final Iterable<XmlElement> currencyElements = root.findElements('Currency');
    final currencies = <CurrencyModel>[];

    /// Her Currency elementini tek tek parse etme
    /// Fail-safe: Bir para biriminde hata olursa o para birimini atla
    for (final element in currencyElements) {
      final Either<Failure, CurrencyModel> currencyResult =
          _parseCurrency(element);
      if (currencyResult.isRight()) {
        currencies.add(currencyResult.getRight().toNullable()!);
      }

      /// Left durumunda (hata) o currency'i atla, diğerlerine devam et
    }

    return right(currencies);
  } catch (e, stackTrace) {
    /// Beklenmeyen liste parse hatası
    return left(
      XmlParseFailure(
        message: 'Failed to parse currencies: $e',
        stackTrace: stackTrace,
      ),
    );
  }
}

/// Tek Bir Currency Element'ini CurrencyModel'e Dönüştürme
///
/// Currency elementi içindeki tüm alanları okuyup CurrencyModel nesnesi oluşturur.
///
/// Parse Edilen Alanlar:
/// - Kod: Türkçe kısa kod (örn: "USD")
/// - CurrencyCode: İngilizce kısa kod (genelde Kod ile aynı)
/// - Unit: Birim (genelde 1, bazı para birimleri için 100)
/// - Isim: Türkçe açık adı (örn: "AMERİKAN DOLARI")
/// - CurrencyName: İngilizce açık adı (örn: "US DOLLAR")
/// - ForexBuying: Döviz alış kuru (banka bu kurdan döviz alır)
/// - ForexSelling: Döviz satış kuru (banka bu kurdan döviz satar)
/// - BanknoteBuying: Efektif alış (fiziksel nakit için)
/// - BanknoteSelling: Efektif satış (fiziksel nakit için)
/// - CrossRateUSD: USD bazlı çapraz kur (opsiyonel)
/// - CrossRateOther: Diğer çapraz kurlar (opsiyonel)
///
/// [element]: Parse edilecek Currency elementi
/// Returns: Either.Right(CurrencyModel) veya Either.Left(XmlParseFailure)
Either<Failure, CurrencyModel> _parseCurrency(XmlElement element) {
  try {
    /// Attribute'lardan temel bilgileri çıkarma
    final String code = element.getAttribute('Kod') ?? '';
    final String currencyCode = element.getAttribute('CurrencyCode') ?? '';
    final String crossOrderStr = element.getAttribute('CrossOrder') ?? '0';

    /// Child elementlerden text içeriklerini okuma
    final String name =
        element.findElements('Isim').firstOrNull?.innerText ?? '';
    final String currencyName =
        element.findElements('CurrencyName').firstOrNull?.innerText ?? '';
    final String forexBuyingStr =
        element.findElements('ForexBuying').firstOrNull?.innerText ?? '0';
    final String forexSellingStr =
        element.findElements('ForexSelling').firstOrNull?.innerText ?? '0';
    final String banknoteBuyingStr =
        element.findElements('BanknoteBuying').firstOrNull?.innerText ?? '0';
    final String banknoteSellingStr =
        element.findElements('BanknoteSelling').firstOrNull?.innerText ?? '0';
    final String crossRateUSD =
        element.findElements('CrossRateUSD').firstOrNull?.innerText ?? '';
    final String crossRateOther =
        element.findElements('CrossRateOther').firstOrNull?.innerText ?? '';

    /// CurrencyCode validasyonu
    /// Her para biriminin mutlaka kodu olmalı
    if (currencyCode.isEmpty) {
      return left(
        const XmlParseFailure(
          message: 'Currency code is empty',
        ),
      );
    }

    /// String değerleri numeric'e çevirme
    /// tryParse kullanarak parse edilemeyen değerler için default değer veriyoruz
    final int unit = int.tryParse(crossOrderStr) ?? 0;
    final double forexBuying = double.tryParse(forexBuyingStr) ?? 0.0;
    final double forexSelling = double.tryParse(forexSellingStr) ?? 0.0;
    final double banknoteBuying = double.tryParse(banknoteBuyingStr) ?? 0.0;
    final double banknoteSelling = double.tryParse(banknoteSellingStr) ?? 0.0;

    /// CurrencyModel oluştur ve döndür
    /// Tüm alanlar doldurulmuş tam bir model nesnesi
    return right(
      CurrencyModel(
        code: code,
        currencyCode: currencyCode,
        unit: unit,
        name: name,
        currencyName: currencyName,
        forexBuying: forexBuying,
        forexSelling: forexSelling,
        banknoteBuying: banknoteBuying,
        banknoteSelling: banknoteSelling,
        crossRateUSD: crossRateUSD,
        crossRateOther: crossRateOther,
      ),
    );
  } catch (e, stackTrace) {
    /// Parse hatası
    /// Bu currency element'i atlanacak
    return left(
      XmlParseFailure(
        message: 'Failed to parse currency element: $e',
        stackTrace: stackTrace,
      ),
    );
  }
}
