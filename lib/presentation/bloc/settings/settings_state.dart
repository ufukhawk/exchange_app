import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.themeMode,
    required this.language,
    required this.stateManagement,
  });
  final ThemeModeType themeMode;
  final LanguageType language;
  final StateManagementType stateManagement;

  @override
  List<Object?> get props => [themeMode, language, stateManagement];

  SettingsLoaded copyWith({
    ThemeModeType? themeMode,
    LanguageType? language,
    StateManagementType? stateManagement,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      stateManagement: stateManagement ?? this.stateManagement,
    );
  }
}
