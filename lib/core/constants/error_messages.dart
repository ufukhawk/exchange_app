/// Error message keys for localization
class ErrorMessageKeys {
  // HTTP Errors
  static const String dataNotFound = 'errorDataNotFound';
  static const String serverNotResponding = 'errorServerNotResponding';
  static const String dataCouldNotBeRetrieved = 'errorDataCouldNotBeRetrieved';

  // Network Errors
  static const String checkInternetConnection = 'errorCheckInternetConnection';
  static const String connectionTimeout = 'errorConnectionTimeout';
  static const String connectionFailed = 'errorConnectionFailed';

  // General Errors
  static const String unexpected = 'errorUnexpected';

  // Date Errors
  static const String weekendDataNotAvailable = 'weekendDataNotAvailable';
  static const String futureDateNotAvailable = 'futureDateNotAvailable';
  static const String dataNotAvailableForDate = 'dataNotAvailableForDate';
}

/// Default error messages (fallback when localization is not available)
class DefaultErrorMessages {
  static const String dataNotFound = 'Seçilen tarih için veri bulunamadı.';
  static const String serverNotResponding =
      'Sunucu şu anda yanıt veremiyor. Lütfen daha sonra tekrar deneyin.';
  static const String dataCouldNotBeRetrieved =
      'Veriler alınamadı. Lütfen tekrar deneyin.';
  static const String checkInternetConnection =
      'İnternet bağlantınızı kontrol edin.';
  static const String connectionTimeout =
      'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
  static const String connectionFailed =
      'Bağlantı hatası oluştu. Lütfen tekrar deneyin.';
  static const String unexpected =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}
