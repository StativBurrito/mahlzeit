import 'package:flutter/material.dart';

/// Peirao Material 3 Theme for Flutter
class PeiraoTheme {
  // 1. Define core colors
  static const Color _peiraoDarkGreen = Color(0xFF1A3F2B);
  static const Color _peiraoLightGreen = Color(0xFFC9D5CC);
  static const Color _peiraoWhite = Color(0xFFFFFFFF);
  static const Color _peiraoGray = Color(0xFF9E9E9E);

  // 2. Light and Dark ColorSchemes
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _peiraoDarkGreen,
    onPrimary: _peiraoWhite,
    secondary: _peiraoLightGreen,
    onSecondary: _peiraoDarkGreen,
    background: _peiraoLightGreen,
    onBackground: _peiraoDarkGreen,
    surface: _peiraoWhite,
    onSurface: _peiraoDarkGreen,
    error: Colors.red,
    onError: _peiraoWhite,
    errorContainer: Colors.red.shade100,
    onErrorContainer: Colors.red.shade700,
    outline: _peiraoGray,
    shadow: Colors.black,
    inverseSurface: _peiraoGray,
    onInverseSurface: _peiraoWhite,
    inversePrimary: _peiraoLightGreen,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _peiraoDarkGreen,
    onPrimary: _peiraoWhite,
    secondary: _peiraoLightGreen,
    onSecondary: _peiraoDarkGreen,
    background: _peiraoDarkGreen,
    onBackground: _peiraoWhite,
    surface: _peiraoDarkGreen,
    onSurface: _peiraoWhite,
    error: Colors.red.shade200,
    onError: Colors.red.shade800,
    errorContainer: Colors.red.shade900,
    onErrorContainer: Colors.red.shade100,
    outline: _peiraoGray,
    shadow: Colors.black,
    inverseSurface: _peiraoGray,
    onInverseSurface: _peiraoWhite,
    inversePrimary: _peiraoLightGreen,
  );

  // 3. Typography matching Peirao style
  static final TextTheme peiraoTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'SansSerif',
      fontWeight: FontWeight.bold,
      fontSize: 56,
      height: 64 / 56,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'SansSerif',
      fontWeight: FontWeight.w600,
      fontSize: 28,
      height: 36 / 28,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'SansSerif',
      fontWeight: FontWeight.normal,
      fontSize: 16,
      height: 24 / 16,
    ),
    labelLarge: TextStyle(
      fontFamily: 'SansSerif',
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 20 / 14,
    ),
  );


  // 5. ThemeData factory
  static ThemeData themeData({bool useDarkMode = false}) {
    final scheme = useDarkMode ? darkColorScheme : lightColorScheme;

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: peiraoTextTheme,
      // Material 3 shape customization
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF0EDDB),
          foregroundColor: _peiraoDarkGreen,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 25),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}