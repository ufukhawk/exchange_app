import 'package:bloc/bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required this.settingsRepository})
      : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<UpdateStateManagementEvent>(_onUpdateStateManagement);
    add(const LoadSettingsEvent());
  }
  final SettingsRepository settingsRepository;

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final ThemeModeType themeMode = await settingsRepository.getThemeMode();
    final LanguageType language = await settingsRepository.getLanguage();
    final StateManagementType stateManagement =
        await settingsRepository.getStateManagement();
    emit(SettingsLoaded(
      themeMode: themeMode,
      language: language,
      stateManagement: stateManagement,
    ));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      await settingsRepository.saveThemeMode(event.themeMode);
      emit((state as SettingsLoaded).copyWith(themeMode: event.themeMode));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      await settingsRepository.saveLanguage(event.language);
      emit((state as SettingsLoaded).copyWith(language: event.language));
    }
  }

  Future<void> _onUpdateStateManagement(
    UpdateStateManagementEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      await settingsRepository.saveStateManagement(event.stateManagement);
      emit((state as SettingsLoaded)
          .copyWith(stateManagement: event.stateManagement));
    }
  }
}
