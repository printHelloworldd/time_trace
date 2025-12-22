import 'package:flutter/material.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_snack_bar_theme.dart';

extension AppThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColors get appColors =>
      extension<AppColors>() ??
      (throw FlutterError('Missing AppColors in ThemeData'));

  AppSnackBarTheme get appSnackBarTheme => extension<AppSnackBarTheme>()!;
}
