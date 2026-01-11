/// Uygulama genelinde kullanılan sabit değerler
/// API URL'leri, timeout süreleri, format pattern'leri vb.
class AppConstants {
  /// TCMB döviz kuru API'sinin base URL'i
  static const String baseUrl = 'https://www.tcmb.gov.tr/kurlar';

  /// Uygulama adı
  static const String appName = 'Exchange Rates';

  /// HTTP istekleri için maksimum bekleme süresi
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Kullanıcıya gösterilecek tarih formatı (örn: 15.01.2024)
  static const String dateFormat = 'dd.MM.yyyy';

  /// API'ye gönderilecek tarih formatı (örn: 15012024)
  static const String apiDateFormat = 'DDMMYYYY';

  /// API'ye gönderilecek ay-yıl formatı (örn: 202401)
  static const String apiMonthYearFormat = 'YYYYMM';

  /// Native platform ile iletişim için güvenlik channel adı
  static const String securityChannelName = 'com.exchange_rates.app/security';

  /// Ekran görüntüsü koruması için method channel adı
  static const String screenshotProtectionChannel = 'screenshot_protection';

  /// Ekran görüntüsü tespiti için event channel adı
  static const String screenshotDetectionChannel = 'screenshot_detection';
}

/// Navigasyon route sabitleri
/// go_router ile kullanılacak rota path'leri
class RouteConstants {
  /// Ana sayfa rotası
  static const String home = '/';

  /// Ayarlar sayfası rotası
  static const String settings = '/settings';
}

/// TCMB kur yayın saati sabitleri
/// Merkez Bankası her gün 15:30'da güncel kurları yayınlar
class PublicationConstants {
  /// Yayın saati (24 saat formatında)
  static const int publicationHour = 15;

  /// Yayın dakikası
  static const int publicationMinute = 30;

  /// Yayın saati string formatı
  static const String publicationTime = '15:30';
}

/// Local storage (SharedPreferences) için key sabitleri
class StorageKeys {
  /// Tema modu tercihi için key (light/dark)
  static const String themeMode = 'theme_mode';

  /// Dil tercihi için key (turkish/english)
  static const String language = 'language';

  /// State management tercihi için key (bloc/getx/mobx)
  static const String stateManagement = 'state_management';
}

/// State management pattern türleri
/// Kullanıcı ayarlardan seçebilir
enum StateManagementType {
  /// GetX pattern (reactive programming)
  getx,

  /// MobX pattern (observable state)
  mobx,

  /// BLoC pattern (event-driven)
  bloc,
}

/// Tema modu seçenekleri
enum ThemeModeType {
  /// Açık tema
  light,

  /// Koyu tema
  dark,
}

/// Dil seçenekleri
enum LanguageType {
  /// İngilizce
  english,

  /// Türkçe
  turkish,
}
