import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/di/shared_dependencies.dart';
import 'core/router/app_router.dart';
import 'core/services/screenshot_protection_service.dart';
import 'core/state_management/state_manager.dart';
import 'core/themes/app_themes.dart';
import 'data/datasources/local/settings_local_datasource.dart';
import 'data/repositories/settings_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedDependencies.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppConfig>(
      future: _loadInitialConfig(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final _AppConfig config = snapshot.data!;
        return _AppRoot(config: config);
      },
    );
  }

  Future<_AppConfig> _loadInitialConfig() async {
    // Create settings repository directly
    final settingsRepository = SettingsRepositoryImpl(
      localDatasource: SettingsLocalDatasourceImpl(
        preferences: SharedDependencies.sharedPreferences,
      ),
    );

    final StateManagementType stateManagement =
        await settingsRepository.getStateManagement();
    final ThemeModeType themeMode = await settingsRepository.getThemeMode();
    final LanguageType language = await settingsRepository.getLanguage();

    final StateManager stateManager = _createStateManager(stateManagement);

    return _AppConfig(
      stateManager: stateManager,
      themeMode: themeMode,
      language: language,
    );
  }

  StateManager _createStateManager(StateManagementType type) {
    switch (type) {
      case StateManagementType.getx:
        return GetXStateManager();
      case StateManagementType.mobx:
        return MobXStateManager();
      case StateManagementType.bloc:
        return BlocStateManager();
    }
  }
}

class _AppConfig {
  _AppConfig({
    required this.stateManager,
    required this.themeMode,
    required this.language,
  });
  final StateManager stateManager;
  final ThemeModeType themeMode;
  final LanguageType language;
}

class _AppRoot extends StatefulWidget {
  const _AppRoot({required this.config});
  final _AppConfig config;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final _screenshotService = ScreenshotProtectionService();

  @override
  void initState() {
    super.initState();
    _setupScreenshotDetection();
  }

  void _setupScreenshotDetection() {
    _screenshotService.onScreenshotDetected.listen((detected) {
      if (detected && mounted) {
        _showScreenshotDialog();
      }
    });
  }

  void _showScreenshotDialog() {
    final BuildContext? context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.screenshotDetectedTitle),
            ),
          ],
        ),
        content: Text(l10n.screenshotDetectedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.config.stateManager.buildReactiveWidget((state) {
      return MaterialApp.router(
        title: 'Exchange Rates',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: state.themeMode == ThemeModeType.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: state.language == LanguageType.turkish
            ? const Locale('tr')
            : const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
        routerConfig: AppRouter.createRouter(widget.config.stateManager),
      );
    });
  }
}
