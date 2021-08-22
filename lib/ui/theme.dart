import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _primaryColor = Color(0xFFf97737);
const MaterialColor _primarySwatch = MaterialColor(0xFFf97737, {
  50: _primaryColor,
  100: _primaryColor,
  200: _primaryColor,
  300: _primaryColor,
  400: _primaryColor,
  500: _primaryColor,
  600: _primaryColor,
  700: _primaryColor,
  800: _primaryColor,
  900: _primaryColor,
});

final _errorColor = Colors.red.shade700;
final _inputBorderSide = BorderSide(color: Colors.grey.shade300, width: 2);
final _inputBorderRadius = BorderRadius.circular(100.0);

ThemeData theme = ThemeData(
  primarySwatch: _primarySwatch,
  backgroundColor: Colors.grey[50],
  scaffoldBackgroundColor: Colors.grey[50],
  focusColor: Colors.greenAccent.shade700,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
  errorColor: _errorColor,
  inputDecorationTheme: InputDecorationTheme(
    constraints: const BoxConstraints(
      minWidth: 125,
      maxWidth: 325,
    ),
    contentPadding: const EdgeInsets.only(left: 30, top: 14, bottom: 14, right: 14),
    border: OutlineInputBorder(
      borderRadius: _inputBorderRadius,
      borderSide: _inputBorderSide,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: _inputBorderRadius,
      borderSide: _inputBorderSide,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: _inputBorderRadius,
      borderSide: _inputBorderSide.copyWith(color: _primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: _inputBorderRadius,
      borderSide: _inputBorderSide.copyWith(color: _errorColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: _inputBorderRadius,
      borderSide: _inputBorderSide.copyWith(color: Colors.grey.shade100),
    ),
    errorStyle: TextStyle(
      color: _errorColor,
      fontSize: 12,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: _primaryColor,
    selectionColor: _primaryColor.withOpacity(0.4),
    selectionHandleColor: _primaryColor,
  ),
  textTheme: const TextTheme(
    headline3: TextStyle(
      fontSize: 48,
      color: _primarySwatch,
      fontWeight: FontWeight.bold,
    ),
    headline4: TextStyle(
      fontSize: 36,
      color: _primarySwatch,
      fontWeight: FontWeight.bold,
    ),
    headline5: TextStyle(
      fontSize: 24,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    headline6: TextStyle(
      fontSize: 20,
      color: Colors.black87,
      fontWeight: FontWeight.normal,
    ),
    // Modifies the style of Input fields such as TextField.
    subtitle1: TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
    button: TextStyle(
      fontSize: 16,
      color: _primarySwatch,
    ),
    overline: TextStyle(
      fontSize: 16,
      color: Colors.black54,
      letterSpacing: 0.6,
    ),
  ),
);
