import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';

/// The app-wide Material theme.
abstract final class AppTheme {
  /// The light theme.
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.gold,
      surface: Colors.white,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      useMaterial3: true,
    );
  }
}
