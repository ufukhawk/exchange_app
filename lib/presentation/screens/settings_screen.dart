import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/state_management/state_manager.dart';
import '../widgets/app_icon.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({
    super.key,
    required this.stateManager,
  });
  final StateManager stateManager;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.onInverseSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settings),
      ),
      body: widget.stateManager.buildReactiveWidget((state) {
        return ListView(
          children: [
            AppSpacing.md.heightBox,
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppIcon(
                        iconData: Icons.developer_mode,
                        backgroundColor: colorScheme.surfaceVariant,
                      ),
                      AppSpacing.md.widthBox,
                      Text(
                        l10n.stateManagement,
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                  AppSpacing.md.heightBox,
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.onInverseSurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            context,
                            'getx',
                            StateManagementType.getx,
                            state.stateManagement,
                          ),
                        ),
                        AppSpacing.sm.widthBox,
                        Expanded(
                          child: _buildSegmentButton(
                            context,
                            'mobx',
                            StateManagementType.mobx,
                            state.stateManagement,
                          ),
                        ),
                        AppSpacing.sm.widthBox,
                        Expanded(
                          child: _buildSegmentButton(
                            context,
                            'bloc',
                            StateManagementType.bloc,
                            state.stateManagement,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.xxl.heightBox,
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: AppIcon(
                      iconData: Icons.dark_mode,
                      backgroundColor: colorScheme.surfaceVariant,
                    ),
                    title: Text(l10n.theme, style: textTheme.titleMedium),
                    trailing: Switch(
                      value: state.themeMode == ThemeModeType.dark,
                      onChanged: (value) {
                        widget.stateManager.updateThemeMode(
                          value ? ThemeModeType.dark : ThemeModeType.light,
                        );
                      },
                    ),
                  ),
                  ExpansionTile(
                    leading: AppIcon(
                      iconData: Icons.language,
                      backgroundColor: colorScheme.surfaceVariant,
                    ),
                    title: Text(l10n.language, style: textTheme.titleMedium),
                    subtitle: Text(
                      state.language == LanguageType.turkish
                          ? l10n.turkish
                          : l10n.english,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    children: [
                      RadioListTile<LanguageType>(
                        title: Text(
                          l10n.turkish,
                          style: textTheme.bodyMedium,
                        ),
                        value: LanguageType.turkish,
                        groupValue: state.language,
                        onChanged: (value) {
                          if (value != null) {
                            widget.stateManager.updateLanguage(value);
                          }
                        },
                      ),
                      RadioListTile<LanguageType>(
                        title: Text(l10n.english, style: textTheme.bodyMedium),
                        value: LanguageType.english,
                        groupValue: state.language,
                        onChanged: (value) {
                          if (value != null) {
                            widget.stateManager.updateLanguage(value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.xxl.heightBox,
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                children: [
                  FutureBuilder<PackageInfo>(
                    future: _packageInfoFuture,
                    builder: (context, snapshot) {
                      final String version = snapshot.data?.version ?? '...';
                      final String buildNumber =
                          snapshot.data?.buildNumber ?? '';
                      return ListTile(
                        leading: AppIcon(
                          iconData: Icons.info_outline,
                          backgroundColor: colorScheme.surfaceVariant,
                        ),
                        title: Text(l10n.version, style: textTheme.titleMedium),
                        trailing: Text(
                          'v$version${buildNumber.isNotEmpty ? " ($buildNumber)" : ""}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: AppIcon(
                      iconData: Icons.account_balance,
                      backgroundColor: colorScheme.surfaceVariant,
                    ),
                    title: Text(l10n.dataSource, style: textTheme.titleMedium),
                    trailing: Text(
                      'TCMB',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.md.heightBox,
          ],
        );
      }),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String label,
    StateManagementType type,
    StateManagementType currentType,
  ) {
    final isSelected = type == currentType;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        if (type != currentType) {
          // Save state management setting

          // Show restart dialog
          if (context.mounted) {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.restart),
                content: Text(l10n.restartRequired),
                actions: [
                  TextButton(
                    child: Text(l10n.cancel),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: Text(l10n.restart),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (confirm ?? false) {
              await widget.stateManager.updateStateManagement(type);
              await Restart.restartApp(
                notificationTitle: l10n.restart,
                notificationBody: l10n.restartRequired,
              );
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
