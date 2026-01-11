import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk sabitleri
/// Design System'e uygun, merkezi renk yönetimi
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryLight = Color(0xFF5AA3F5);
  static const Color primaryDark = Color(0xFF0D5FB8);

// appbar background color
  static const Color appBarLight = Color(0xFFFAFAFA);
  static const Color appBarDark = Color(0xFF1B252D);

  static const Color borderColorLight = Color(0xFFE0E0E0);
  static const Color borderColorDark = Color(0xFF1B252D);

  // Background Colors
  static const Color scaffoldLight = Color(0xFFFAFAFA); // #FAFAFA
  static const Color scaffoldDark = Color(0xFF0F1921); // Dark background

  // icon background color
  static const Color iconBackgroundLight = Color(0xFFFAFAFA);
  static const Color iconBackgroundDark = Color.fromARGB(255, 195, 195, 195);

  // Dark Theme Specific Colors
  static const Color darkSurface =
      Color(0xFF1B252D); // Card/Container background
  static const Color darkSurfaceVariant = Color(0xFF293039); // Unselected items
  static const Color lightSurfaceVariant =
      Color.fromARGB(255, 230, 230, 230); // Unselected items
  static const Color darkSurfaceSelected =
      Color(0xFF137FEC); // Selected items (primary)

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Dark Theme Text Colors
  static const Color textDarkPrimary = Colors.white;
  static const Color textDarkSecondary =
      Color(0xFFB0B0B0); // Light gray for secondary text
  static const Color textDarkTertiary =
      Color(0xFF808080); // Medium gray for tertiary text

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2A3441); // Dark theme border

  // Error Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFB71C1C);

  // Success Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Info Colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral Colors
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000); // 50% opacity
  static const Color overlayDark = Color(0x80FFFFFF); // 50% opacity

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% opacity
  static const Color shadowMedium = Color(0x33000000); // 20% opacity
  static const Color shadowDark = Color(0x4D000000); // 30% opacity
}
