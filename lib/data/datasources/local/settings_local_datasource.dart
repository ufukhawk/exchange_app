import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

abstract class SettingsLocalDatasource {
  Future<ThemeModeType> getThemeMode();
  Future<void> saveThemeMode(ThemeModeType themeMode);
  Future<LanguageType> getLanguage();
  Future<void> saveLanguage(LanguageType language);
  Future<StateManagementType> getStateManagement();
  Future<void> saveStateManagement(StateManagementType stateManagement);
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  SettingsLocalDatasourceImpl({required this.preferences});
  final SharedPreferences preferences;

  @override
  Future<ThemeModeType> getThemeMode() async {
    final String? value = preferences.getString(StorageKeys.themeMode);
    if (value == null) {
      return ThemeModeType.light;
    }
    return ThemeModeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeModeType.light,
    );
  }

  @override
  Future<void> saveThemeMode(ThemeModeType themeMode) async {
    await preferences.setString(StorageKeys.themeMode, themeMode.name);
  }

  @override
  Future<LanguageType> getLanguage() async {
    final String? value = preferences.getString(StorageKeys.language);
    if (value == null) {
      return LanguageType.english;
    }
    return LanguageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LanguageType.english,
    );
  }

  @override
  Future<void> saveLanguage(LanguageType language) async {
    await preferences.setString(StorageKeys.language, language.name);
  }

  @override
  Future<StateManagementType> getStateManagement() async {
    final String? value = preferences.getString(StorageKeys.stateManagement);
    if (value == null) {
      return StateManagementType.bloc;
    }
    return StateManagementType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StateManagementType.bloc,
    );
  }

  @override
  Future<void> saveStateManagement(StateManagementType stateManagement) async {
    await preferences.setString(
        StorageKeys.stateManagement, stateManagement.name);
  }
}
