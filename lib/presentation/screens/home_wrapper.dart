import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/services/screenshot_protection_service.dart';
import '../../core/state/app_state.dart';
import '../../core/state_management/state_manager.dart';
import 'home_screen.dart';

class HomeWrapper extends StatefulWidget {

  const HomeWrapper({
    super.key,
    required this.stateManager,
  });
  final StateManager stateManager;

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  final _screenshotService = ScreenshotProtectionService();
  final _showWarningDueToScreenshot = ValueNotifier<bool>(false);
  Timer? _warningTimer;

  @override
  void initState() {
    super.initState();
    _listenToScreenshots();
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    _showWarningDueToScreenshot.dispose();
    super.dispose();
  }

  void _listenToScreenshots() {
    // Screenshot algılandığında 3 saniye uyarı göster
    _screenshotService.onScreenshotDetected.listen((detected) {
      if (detected) {
        _showWarningDueToScreenshot.value = true;

        // 3 saniye sonra geri dön
        _warningTimer?.cancel();
        _warningTimer = Timer(const Duration(seconds: 3), () {
          _showWarningDueToScreenshot.value = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _screenshotService.onScreenRecordingStatusChanged,
      initialData: false,
      builder: (context, recordingSnapshot) {
        final bool isScreenRecording = recordingSnapshot.data ?? false;

        return ValueListenableBuilder<bool>(
          valueListenable: _showWarningDueToScreenshot,
          builder: (context, showWarning, _) {
            return widget.stateManager.buildReactiveWidget(
              (AppState state) {
                // Show warning if screenshot just taken OR screen recording active
                if (showWarning || isScreenRecording) {
                  return _buildScreenRecordingWarning(context);
                }
                return HomeScreen(
                  stateManager: widget.stateManager,
                  state: state,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScreenRecordingWarning(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.currency_exchange, size: 28),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.screenshotDetectedTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.screenshotDetectedMessage,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
