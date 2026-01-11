import 'package:mobx/mobx.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_store.g.dart';

// ignore: library_private_types_in_public_api
class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  _SettingsStore({required this.settingsRepository}) {
    loadSettings();
  }
  final SettingsRepository settingsRepository;

  @observable
  ThemeModeType themeMode = ThemeModeType.light;

  @observable
  LanguageType language = LanguageType.english;

  @observable
  StateManagementType stateManagement = StateManagementType.getx;

  @action
  Future<void> loadSettings() async {
    themeMode = await settingsRepository.getThemeMode();
    language = await settingsRepository.getLanguage();
    stateManagement = await settingsRepository.getStateManagement();
  }

  @action
  Future<void> updateThemeMode(ThemeModeType newThemeMode) async {
    await settingsRepository.saveThemeMode(newThemeMode);
    themeMode = newThemeMode;
  }

  @action
  Future<void> updateLanguage(LanguageType newLanguage) async {
    await settingsRepository.saveLanguage(newLanguage);
    language = newLanguage;
  }

  @action
  Future<void> updateStateManagement(
      StateManagementType newStateManagement) async {
    await settingsRepository.saveStateManagement(newStateManagement);
    stateManagement = newStateManagement;
  }
}
