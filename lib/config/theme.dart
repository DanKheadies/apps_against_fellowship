import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// // TBD
// Color neutral100 = const Color(0xFF1e1e1f);
const primary = Color(0xFFAB47BC);
const primaryDark = Color(0xFF790e8b);
const primaryVariant = Color(0xFFdf78ef);
const colorOnPrimary = Color(0xFFFFFFFF);
const colorOnPrimaryVariant = Color(0xDD000000);

const secondary = Color(0xFF00BCD4);
const secondaryLight = Color(0xFF80DEEA);
const secondaryDark = Color(0xFF006064);

const surface = Color(0xFF3C3C3C);
const surfaceLight = Color(0xFF4F4F4F);
const surfaceDark = Color(0xFF303030);
const responseCardBackground = Color(0xFFF2F2F2);

const error = Color(0xFFFF5252);

const addPhotoBackground = Color(0xFF666666);
const addPhotoForeground = Colors.white70;

const aafText = TextTheme(
  // heading xxlarge
  headlineLarge: TextStyle(
    color: surface,
    // fontFamily: 'Inter',
    fontSize: 48,
    fontWeight: FontWeight.bold,
    // lineHeight: 48,
  ),
  // // heading xlarge
  // headlineMedium: TextStyle(
  //   color: neutral100,
  //   fontFamily: 'Inter',
  //   fontSize: 28,
  //   fontWeight: FontWeight.w600,
  //   // lineHeight: 36,
  // ),
  // // heading large
  // headlineSmall: TextStyle(
  //   color: neutral100,
  //   fontFamily: 'Inter',
  //   fontSize: 20,
  //   fontWeight: FontWeight.w600,
  //   // lineHeight: 24,
  // ),
  // // heading medium
  // titleLarge: TextStyle(
  //   color: neutral100,
  //   fontFamily: 'Inter',
  //   fontSize: 16,
  //   fontWeight: FontWeight.w600,
  //   // lineHeight: 20,
  // ),
  // // heading small
  titleMedium: TextStyle(
    // color: neutral100,
    // fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    // lineHeight: 18,
  ),
  // // heading xsmall
  titleSmall: TextStyle(
    // color: neutral100,
    // fontFamily: 'Inter',
    fontSize: 12,
    // lineHeight: 16,
  ),
  // // paragraph large
  bodyLarge: TextStyle(
    // color: neutral100,
    // fontFamily: 'Inter',
    fontSize: 16,
    // lineHeight: 20,
  ),
  // // paragraph medium
  // bodyMedium: TextStyle(
  //   color: neutral100,
  //   fontFamily: 'Inter',
  //   fontSize: 14,
  //   // lineHeight: 18,
  // ),
  // // paragraph small
  // bodySmall: TextStyle(
  //   color: neutral100,
  //   fontFamily: 'Inter',
  //   fontSize: 12,
  //   // lineHeight: 16,
  // ),
);

ThemeData lightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.light().copyWith(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: primaryVariant,
      primaryContainer: primaryDark,
      // onPrimaryContainer: pcPrimaryLight,
      secondary: primary,
      // onSecondary: pcSecondaryVeryLight,
      // secondaryContainer: pcSecondaryDark,
      // onSecondaryContainer: pcSecondaryLight,
      tertiary: Colors.white38,
      tertiaryContainer: Colors.white70,
      onTertiary: Colors.grey[700],
      // onTertiaryContainer: pcInfoVeryLight,
      error: error,
      // errorContainer: pcErrorVeryLight,
      // onError: pcWarningBase,
      // onErrorContainer: pcWarningVeryLight,
      background: Colors.white,
      // onBackground: pcNeutral600,
      // onSurfaceVariant: pcNeutral500,
      // onSurface: pcNeutral400,
      // surfaceVariant: pcNeutral300,
      // surfaceTint: pcNeutral200,
      surface: surface,
      onSurface: Colors.white, // colorOnCard
      onSurfaceVariant: Colors.white54, // secondaryColorOnCard
      surfaceVariant: Colors.white38, // tertiaryColorOnCard
    ),
    appBarTheme: const AppBarTheme(
      color: surfaceDark,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: surfaceDark,
    ),
    // cardColor: Colors.white,
    cardColor: Colors.grey[700],
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      actionTextColor: primary,
      backgroundColor: surfaceLight,
      contentTextStyle: aafText.titleMedium,
      disabledActionTextColor: Colors.white30,
    ),
    textTheme: aafText,
  );
}

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: primaryVariant,
      onPrimary: primaryDark,
      primaryContainer: primaryVariant,
      secondary: primaryVariant,
      tertiary: Colors.white38,
      tertiaryContainer: Colors.white70,
      onTertiary: Colors.grey[700],
      error: error,
      background: Colors.grey[700],
      surface: surface,
      onSurface: Colors.black87,
      onSurfaceVariant: Colors.black38,
      surfaceVariant: Colors.black26,
    ),
    appBarTheme: const AppBarTheme(
      color: surface,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: surface,
    ),
    cardColor: Colors.grey[700],
    snackBarTheme: SnackBarThemeData(
      actionTextColor: primary,
      backgroundColor: surfaceDark,
      contentTextStyle: aafText.titleMedium,
      disabledActionTextColor: Colors.white30,
    ),
  );
}
