import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController({required this.settingsRepository});
  final SettingsRepository settingsRepository;

  final Rx<ThemeModeType> themeMode = ThemeModeType.light.obs;
  final Rx<LanguageType> language = LanguageType.english.obs;
  final Rx<StateManagementType> stateManagement = StateManagementType.getx.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    themeMode.value = await settingsRepository.getThemeMode();
    language.value = await settingsRepository.getLanguage();
    stateManagement.value = await settingsRepository.getStateManagement();
  }

  Future<void> updateThemeMode(ThemeModeType newThemeMode) async {
    await settingsRepository.saveThemeMode(newThemeMode);
    themeMode.value = newThemeMode;
  }

  Future<void> updateLanguage(LanguageType newLanguage) async {
    await settingsRepository.saveLanguage(newLanguage);
    language.value = newLanguage;
  }

  Future<void> updateStateManagement(
      StateManagementType newStateManagement) async {
    await settingsRepository.saveStateManagement(newStateManagement);
    stateManagement.value = newStateManagement;
  }
}
