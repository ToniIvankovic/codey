import 'package:flutter/material.dart';

abstract class AppTheme {
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    surface: Color(0xffffffff),
    onSurface: Color(0xff1d1d1d),
    primary: Color.fromARGB(255, 20, 137, 135),
    onPrimary: Color(0xfff8f8f8),
    primaryContainer: Color(0xffcbf3f0),
    onPrimaryContainer: Color.fromARGB(255, 20, 137, 135),
    inversePrimary: Color(0xffcbf3f0),
    secondary: Color(0xfffedb71),
    onSecondary: Color(0xff1d1d1d),
    error: Color.fromARGB(255, 233, 76, 76),
    onError: Color(0xfff8f8f8),
    errorContainer: Color.fromARGB(255, 242, 194, 196),
    onErrorContainer: Color.fromARGB(255, 209, 66, 66),
    inverseSurface: Color(0xfff8f8f8),
    onInverseSurface: Color(0xff1d1d1d),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    surface: Color.fromARGB(255, 40, 48, 47),
    onSurface: Color.fromARGB(255, 177, 211, 209),
    primary: Color.fromARGB(255, 20, 137, 135),
    onPrimary: Color(0xfff8f8f8),
    primaryContainer: Color.fromARGB(255, 41, 100, 95),
    onPrimaryContainer: Color(0xffcbf3f0),
    inversePrimary: Color.fromARGB(255, 23, 60, 53),
    secondary: Color(0xfffedb71),
    onSecondary: Color(0xff1d1d1d),
    error: Color.fromARGB(255, 235, 93, 93),
    onError: Color(0xfff8f8f8),
    errorContainer: Color.fromARGB(255, 139, 47, 50),
    onErrorContainer: Color.fromARGB(255, 255, 209, 210),
    inverseSurface: Color.fromARGB(255, 58, 59, 59),
    onInverseSurface: Color.fromARGB(255, 177, 211, 209),
  );

  static final light = ThemeData(
    colorScheme: _lightScheme,
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightScheme.primary,
        foregroundColor: _lightScheme.onPrimary,
      ),
    ),
  );

  static final dark = ThemeData(
    colorScheme: _darkScheme,
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkScheme.primary,
        foregroundColor: _darkScheme.onPrimary,
      ),
    ),
  );
}
