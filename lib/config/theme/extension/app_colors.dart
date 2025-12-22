import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color hint;
  final Color text;

  AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.hint,
    required this.text,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceHighlight,
    Color? hint,
    Color? text,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      hint: hint ?? this.hint,
      text: text ?? this.text,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHighlight: Color.lerp(
        surfaceHighlight,
        other.surfaceHighlight,
        t,
      )!,
      hint: Color.lerp(hint, other.hint, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }
}
