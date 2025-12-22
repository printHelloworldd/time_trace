import 'package:flutter/material.dart';
import 'package:time_trace/config/theme/extension/snack_bar_style.dart';

class AppSnackBarTheme extends ThemeExtension<AppSnackBarTheme> {
  final SnackBarStyle error;
  final SnackBarStyle warning;
  final SnackBarStyle success;
  final EdgeInsetsGeometry padding;

  const AppSnackBarTheme({
    required this.error,
    required this.warning,
    required this.success,
    required this.padding,
  });

  @override
  AppSnackBarTheme copyWith({
    SnackBarStyle? error,
    SnackBarStyle? warning,
    SnackBarStyle? success,
    EdgeInsetsGeometry? padding,
  }) {
    return AppSnackBarTheme(
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      padding: padding ?? this.padding,
    );
  }

  @override
  AppSnackBarTheme lerp(ThemeExtension<AppSnackBarTheme>? other, double t) {
    if (other is! AppSnackBarTheme) return this;
    return this;
  }
}
