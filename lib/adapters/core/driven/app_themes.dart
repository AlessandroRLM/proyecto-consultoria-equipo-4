import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Tonalidades de rojo
  static const Color primary_100 = Color.fromARGB(255, 252, 233, 233);
  static const Color primary_200 = Color.fromARGB(255, 247, 203, 203);
  static const Color primary_300 = Color.fromARGB(255, 240, 162, 162);
  static const Color primary_400 = Color.fromARGB(255, 233, 118, 118);
  static const Color primary_500 = Color.fromARGB(255, 226, 77, 77);
  static const Color primary_600 = Color.fromARGB(255, 220, 38, 38);
  static const Color primary_700 = Color.fromARGB(255, 187, 32, 32);
  static const Color primary_800 = Color.fromARGB(255, 156, 27, 27);
  static const Color primary_900 = Color.fromARGB(255, 125, 22, 22);
  static const Color primary_1000 = Color.fromARGB(255, 99, 17, 17);

  // Tonalidades de negro
  static const Color black_100 = Color.fromARGB(255, 255, 255, 255);
  static const Color black_200 = Color.fromARGB(255, 252, 252, 252);
  static const Color black_300 = Color.fromARGB(255, 245, 245, 245);
  static const Color black_400 = Color.fromARGB(255, 240, 240, 240);
  static const Color black_500 = Color.fromARGB(255, 217, 217, 217);
  static const Color black_600 = Color.fromARGB(255, 191, 191, 191);
  static const Color black_700 = Color.fromARGB(255, 140, 140, 140);
  static const Color black_800 = Color.fromARGB(255, 89, 89, 89);
  static const Color black_900 = Color.fromARGB(255, 69, 69, 69);
  static const Color black_1000 = Color.fromARGB(255, 38, 38, 38);
  static const Color black_1100 = Color.fromARGB(255, 31, 31, 31);
  static const Color black_1200 = Color.fromARGB(255, 20, 20, 20);
  static const Color black_1300 = Color.fromARGB(255, 0, 0, 0);

  // Estilos de texto 
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.openSans(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 40.8 / 34,
      letterSpacing: 0,
    ), // h1
    displayMedium: GoogleFonts.openSans(
      fontSize: 27,
      fontWeight: FontWeight.w600,
      height: 32.4 / 27,
      letterSpacing: 0,
    ), // h2
    displaySmall: GoogleFonts.openSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 26.4 / 22,
      letterSpacing: 0,
    ), // h3
    headlineMedium: GoogleFonts.openSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 21.6 / 18,
      letterSpacing: 0,
    ), // h4
    titleLarge: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 19.2 / 16,
      letterSpacing: 0,
    ), // largeBodyStrong
    titleMedium: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 110 / 16,
      letterSpacing: 0,
    ), // largeBody
    bodyLarge: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 16.8 / 14,
      letterSpacing: 0,
    ), // bodyStrong
    bodyMedium: GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 15.4 / 14,
      letterSpacing: 0,
    ), // body
    bodySmall: GoogleFonts.openSans(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 13.2 / 11,
      letterSpacing: 0,
    ), // smallBodyStrong
    labelLarge: GoogleFonts.openSans(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 12.1 / 11,
      letterSpacing: 0,
    ), // smallBody
    labelMedium: GoogleFonts.openSans(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      height: 10.8 / 9,
      letterSpacing: 0,
    ), // extraSmallBodyStrong
    labelSmall: GoogleFonts.openSans(
      fontSize: 9,
      fontWeight: FontWeight.w400,
      height: 110 / 9, 
      letterSpacing: 0,
    ), // extraSmallBody
  );

  static final ThemeData light = ThemeData(
    textTheme: textTheme,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary_600,
      onPrimary: black_100,
      secondary: black_1000,
      onSecondary: black_100,
      error: primary_600,
      onError: black_100,
      surface: black_100,
      onSurface: black_1300,
      outlineVariant: black_500,
    ),
  );

  static final ThemeData dark = ThemeData(
    textTheme: textTheme,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primary_600,
      onPrimary: black_100,
      secondary: black_1000,
      onSecondary: black_100,
      error: primary_600,
      onError: black_100,
      surface: black_1000,
      onSurface: black_200,
      outlineVariant: black_500,
    ),
  );
}