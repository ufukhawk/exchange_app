import 'package:equatable/equatable.dart';
import '../../../core/constants/app_constants.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateThemeModeEvent extends SettingsEvent {
  const UpdateThemeModeEvent({required this.themeMode});
  final ThemeModeType themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class UpdateLanguageEvent extends SettingsEvent {
  const UpdateLanguageEvent({required this.language});
  final LanguageType language;

  @override
  List<Object?> get props => [language];
}

class UpdateStateManagementEvent extends SettingsEvent {
  const UpdateStateManagementEvent({required this.stateManagement});
  final StateManagementType stateManagement;

  @override
  List<Object?> get props => [stateManagement];
}
