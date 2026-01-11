import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Yeniden kullanılabilir icon widget'ı
/// Design System'e uygun, özelleştirilebilir icon container'ı
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconData,
    this.size,
    this.radius,
    this.backgroundColor,
    this.iconColor,
    this.padding,
  });

  final IconData iconData;
  final double? size;
  final double? radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double defaultSize = size ?? AppIconSize.lg;
    final double defaultRadius = radius ?? AppRadius.sm;
    final Color defaultBgColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final Color defaultIconColor = iconColor ?? colorScheme.onPrimaryContainer;
    final EdgeInsets defaultPadding =
        padding ?? const EdgeInsets.all(AppSpacing.sm);

    // Eğer backgroundColor transparent veya null ise, padding kullanma
    final bool hasBackground =
        defaultBgColor != Colors.transparent && defaultBgColor.alpha > 0;

    return Container(
      width: hasBackground
          ? defaultSize + (defaultPadding.horizontal)
          : defaultSize,
      height:
          hasBackground ? defaultSize + (defaultPadding.vertical) : defaultSize,
      decoration: hasBackground
          ? BoxDecoration(
              color: defaultBgColor,
              borderRadius: BorderRadius.circular(defaultRadius),
            )
          : null,
      padding: hasBackground ? defaultPadding : null,
      child: Icon(
        iconData,
        size: defaultSize,
        color: defaultIconColor,
      ),
    );
  }
}
