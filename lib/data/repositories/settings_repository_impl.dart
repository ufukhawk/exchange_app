import '../../core/constants/app_constants.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this.localDatasource});
  final SettingsLocalDatasource localDatasource;

  @override
  Future<ThemeModeType> getThemeMode() async {
    return localDatasource.getThemeMode();
  }

  @override
  Future<void> saveThemeMode(ThemeModeType themeMode) async {
    await localDatasource.saveThemeMode(themeMode);
  }

  @override
  Future<LanguageType> getLanguage() async {
    return localDatasource.getLanguage();
  }

  @override
  Future<void> saveLanguage(LanguageType language) async {
    await localDatasource.saveLanguage(language);
  }

  @override
  Future<StateManagementType> getStateManagement() async {
    return localDatasource.getStateManagement();
  }

  @override
  Future<void> saveStateManagement(StateManagementType stateManagement) async {
    await localDatasource.saveStateManagement(stateManagement);
  }
}
