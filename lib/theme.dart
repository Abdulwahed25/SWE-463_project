import 'package:flutter/material.dart';

/// Souq color palette, taken from the Figma design (KFUPM teal).
class SouqColors {
  SouqColors._();

  static const Color teal = Color(0xFF2E5B61); // primary: headers, buttons
  static const Color green = Color(0xFF3D7349); // links, "Available" badge
  static const Color text = Color(0xFF1F3337); // main text
  static const Color subText = Color(0xFF5E6B6D); // secondary text
  static const Color hint = Color(0xFF8E999B); // placeholders
  static const Color background = Color(0xFFF1F4F4); // screen background
  static const Color field = Color(0xFFF6F8F8); // text field fill
  static const Color border = Color(0xFFD3DADB); // field and chip borders
  static const Color error = Color(0xFFC62828); // validation errors
  static const Color errorBackground = Color(0xFFFDEDED);
  static const Color sold = Color(0xFF5E6B6D); // "Sold" badge
}

/// Shared corner radius used by fields, buttons and cards.
const double kSouqRadius = 10;

OutlineInputBorder _fieldBorder(Color color, [double width = 1]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(kSouqRadius),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Material 3 theme for the whole app. Use it in main.dart:
///   MaterialApp(theme: souqTheme, ...)
final ThemeData souqTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: SouqColors.teal,
    primary: SouqColors.teal,
    secondary: SouqColors.green,
    error: SouqColors.error,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: SouqColors.background,

  appBarTheme: const AppBarTheme(
    backgroundColor: SouqColors.teal,
    foregroundColor: Colors.white,
    centerTitle: false,
    elevation: 0,
  ),

  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: SouqColors.text),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SouqColors.text),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SouqColors.text),
    bodyLarge: TextStyle(fontSize: 15, color: SouqColors.text),
    bodyMedium: TextStyle(fontSize: 14, color: SouqColors.subText),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SouqColors.text),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: SouqColors.field,
    hintStyle: const TextStyle(color: SouqColors.hint),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: _fieldBorder(SouqColors.border),
    enabledBorder: _fieldBorder(SouqColors.border),
    focusedBorder: _fieldBorder(SouqColors.teal, 1.5),
    errorBorder: _fieldBorder(SouqColors.error, 1.5),
    focusedErrorBorder: _fieldBorder(SouqColors.error, 1.5),
    errorStyle: const TextStyle(color: SouqColors.error, fontSize: 13),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: SouqColors.teal,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kSouqRadius)),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: SouqColors.teal,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: SouqColors.teal, width: 1.5),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kSouqRadius)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: SouqColors.green,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: SouqColors.teal,
    side: const BorderSide(color: SouqColors.border),
    shape: const StadiumBorder(),
    labelStyle: const TextStyle(color: SouqColors.text, fontWeight: FontWeight.w500),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    checkmarkColor: Colors.white,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    clipBehavior: Clip.antiAlias,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Color(0xFFE2EBED),
    labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: SouqColors.text,
    behavior: SnackBarBehavior.floating,
  ),
);
