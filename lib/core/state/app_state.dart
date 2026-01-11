import '../../domain/entities/exchange_rate_entity.dart';
import '../constants/app_constants.dart';

/// Uygulamanın global state modeli
/// Tüm state management pattern'leri (BLoC, GetX, MobX) bu state'i kullanır
/// Immutable pattern: Her değişiklik yeni instance oluşturur (copyWith)
class AppState {
  AppState({
    this.isConnected = true,
    this.isLoading = false,
    this.errorMessage = '',
    this.currentExchangeRate,
    DateTime? selectedDate,
    Map<String, double>? convertedAmounts,
    this.themeMode = ThemeModeType.light,
    this.language = LanguageType.english,
    this.stateManagement = StateManagementType.bloc,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        convertedAmounts = convertedAmounts ?? {};

  /// İnternet bağlantısı durumu
  bool isConnected;

  /// API isteği devam ediyor mu?
  bool isLoading;

  /// Hata mesajı (boş string = hata yok)
  String errorMessage;

  /// Mevcut döviz kuru verisi (null = henüz yüklenmedi)
  ExchangeRateEntity? currentExchangeRate;

  /// Kullanıcının seçtiği tarih
  DateTime selectedDate;

  /// TRY'den diğer para birimlerine çevrilmiş tutarlar
  /// Örnek: {"USD": 31.25, "EUR": 28.50}
  Map<String, double> convertedAmounts;

  /// Tema modu (light/dark)
  ThemeModeType themeMode;

  /// Uygulama dili (turkish/english)
  LanguageType language;

  /// Aktif state management pattern'i
  StateManagementType stateManagement;

  /// Immutable update: Sadece belirtilen alanları değiştir, geri kalanı koru
  /// Flutter'da state update için best practice
  /// Örnek: state.copyWith(isLoading: true)
  AppState copyWith({
    bool? isConnected,
    bool? isLoading,
    String? errorMessage,
    ExchangeRateEntity? currentExchangeRate,
    DateTime? selectedDate,
    Map<String, double>? convertedAmounts,
    ThemeModeType? themeMode,
    LanguageType? language,
    StateManagementType? stateManagement,
  }) {
    return AppState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentExchangeRate: currentExchangeRate ?? this.currentExchangeRate,
      selectedDate: selectedDate ?? this.selectedDate,
      convertedAmounts: convertedAmounts ?? this.convertedAmounts,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      stateManagement: stateManagement ?? this.stateManagement,
    );
  }
}
