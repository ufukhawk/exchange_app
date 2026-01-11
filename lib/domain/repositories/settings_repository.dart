import '../../core/constants/app_constants.dart';

abstract class SettingsRepository {
  Future<ThemeModeType> getThemeMode();
  Future<void> saveThemeMode(ThemeModeType themeMode);
  Future<LanguageType> getLanguage();
  Future<void> saveLanguage(LanguageType language);
  Future<StateManagementType> getStateManagement();
  Future<void> saveStateManagement(StateManagementType stateManagement);
}
