// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$themeModeAtom =
      Atom(name: '_SettingsStore.themeMode', context: context);

  @override
  ThemeModeType get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeModeType value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$languageAtom =
      Atom(name: '_SettingsStore.language', context: context);

  @override
  LanguageType get language {
    _$languageAtom.reportRead();
    return super.language;
  }

  @override
  set language(LanguageType value) {
    _$languageAtom.reportWrite(value, super.language, () {
      super.language = value;
    });
  }

  late final _$stateManagementAtom =
      Atom(name: '_SettingsStore.stateManagement', context: context);

  @override
  StateManagementType get stateManagement {
    _$stateManagementAtom.reportRead();
    return super.stateManagement;
  }

  @override
  set stateManagement(StateManagementType value) {
    _$stateManagementAtom.reportWrite(value, super.stateManagement, () {
      super.stateManagement = value;
    });
  }

  late final _$loadSettingsAsyncAction =
      AsyncAction('_SettingsStore.loadSettings', context: context);

  @override
  Future<void> loadSettings() {
    return _$loadSettingsAsyncAction.run(() => super.loadSettings());
  }

  late final _$updateThemeModeAsyncAction =
      AsyncAction('_SettingsStore.updateThemeMode', context: context);

  @override
  Future<void> updateThemeMode(ThemeModeType newThemeMode) {
    return _$updateThemeModeAsyncAction
        .run(() => super.updateThemeMode(newThemeMode));
  }

  late final _$updateLanguageAsyncAction =
      AsyncAction('_SettingsStore.updateLanguage', context: context);

  @override
  Future<void> updateLanguage(LanguageType newLanguage) {
    return _$updateLanguageAsyncAction
        .run(() => super.updateLanguage(newLanguage));
  }

  late final _$updateStateManagementAsyncAction =
      AsyncAction('_SettingsStore.updateStateManagement', context: context);

  @override
  Future<void> updateStateManagement(StateManagementType newStateManagement) {
    return _$updateStateManagementAsyncAction
        .run(() => super.updateStateManagement(newStateManagement));
  }

  @override
  String toString() {
    return '''
themeMode: ${themeMode},
language: ${language},
stateManagement: ${stateManagement}
    ''';
  }
}
