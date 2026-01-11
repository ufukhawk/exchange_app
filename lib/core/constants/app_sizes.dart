import 'package:flutter/material.dart';

/// Design System - Spacing, Padding, Radius ve diğer boyut sabitleri
class AppSpacing {
  AppSpacing._();

  // Spacing (SizedBox, Gap, EdgeInsets için)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;
}

class AppRadius {
  AppRadius._();

  // Border Radius
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circle = 999.0;
}

class AppIconSize {
  AppIconSize._();

  static const double xs = 16.0;
  static const double sm = 18.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;
}

class AppContainerSize {
  AppContainerSize._();

  // Özel container boyutları
  static const double currencyCardWidth = 48.0;
  static const double currencyCardHeight = 48.0;
  static const double weekCalendarHeight = 60.0;
  static const double weekCalendarItemWidth = 56.0;
  static const double keyboardToolbarHeight = 50.0;
}

/// Extension'lar - Kullanımı kolaylaştırır
extension SpacingExtension on num {
  // SizedBox height
  SizedBox get heightBox => SizedBox(height: toDouble());

  // SizedBox width
  SizedBox get widthBox => SizedBox(width: toDouble());
}
