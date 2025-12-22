import 'package:flutter/material.dart';
import 'package:time_trace/config/theme/extension/app_colors.dart';
import 'package:time_trace/config/theme/extension/app_snack_bar_theme.dart';
import 'package:time_trace/config/theme/extension/snack_bar_style.dart';

enum AppTheme { lightTheme, darkTheme }

extension AppThemeX on AppTheme {
  static String getThemeLabel(AppTheme theme) {
    switch (theme) {
      case AppTheme.lightTheme:
        return 'Light';
      case AppTheme.darkTheme:
        return 'Dark';
    }
  }
}

class AppThemeData {
  static final lightColors = AppColors(
    primary: Colors.black,
    secondary: Colors.grey[300]!,
    background: Colors.grey[300]!,
    surface: Colors.grey[400]!,
    surfaceHighlight: Colors.grey[600]!,
    hint: Colors.grey[800]!,
    text: Colors.black,
  );

  static final darkColors = AppColors(
    primary: Colors.white,
    secondary: Colors.grey[500]!,
    background: Colors.black,
    surface: Colors.grey[700]!,
    surfaceHighlight: Colors.grey[300]!,
    hint: Colors.grey[500]!,
    text: Colors.white,
  );

  static ThemeData buildTheme(AppTheme theme) {
    final AppColors colors;

    switch (theme) {
      case AppTheme.lightTheme:
        colors = lightColors;
      case AppTheme.darkTheme:
        colors = darkColors;
    }

    final brightness =
        theme == AppTheme.lightTheme ? Brightness.light : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.background,
      ),
      primaryColor: colors.primary,
      textSelectionTheme: TextSelectionThemeData(cursorColor: colors.primary),
      textTheme: _buildTextTheme(colors.text),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: colors.text,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.secondary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.background,
        titleTextStyle: TextStyle(color: colors.text, fontSize: 22),
        contentTextStyle: TextStyle(color: colors.text, fontSize: 16),
      ),
      hintColor: colors.hint,
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(color: colors.text, fontSize: 24),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.background,
        filled: true,
        hintStyle: TextStyle(color: colors.hint),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.surfaceHighlight, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.primary, width: 2.0),
        ),
      ),
    ).copyWith(
      extensions: [
        AppColors(
          primary: colors.primary,
          secondary: colors.secondary,
          background: colors.background,
          surface: colors.surface,
          surfaceHighlight: colors.surfaceHighlight,
          hint: colors.hint,
          text: colors.text,
        ),
        AppSnackBarTheme(
          error: SnackBarStyle(
            backgroundColor: Colors.red[600]!,
            textColor: Colors.black,
            fontSize: 16,
          ),
          warning: SnackBarStyle(
            backgroundColor: Colors.yellow[600]!,
            textColor: Colors.black,
            fontSize: 16,
          ),
          success: SnackBarStyle(
            backgroundColor: Colors.green[600]!,
            textColor: Colors.black,
            fontSize: 16,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ],
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(color: textColor),
      displayMedium: TextStyle(color: textColor),
      displaySmall: TextStyle(color: textColor),
      headlineLarge: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      headlineSmall: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
      labelLarge: TextStyle(color: textColor),
      labelMedium: TextStyle(color: textColor),
      labelSmall: TextStyle(color: textColor),
    );
  }

  static final Map<AppTheme, ThemeData> themes = {
    AppTheme.lightTheme: buildTheme(AppTheme.lightTheme),
    AppTheme.darkTheme: buildTheme(AppTheme.darkTheme),
  };
}
