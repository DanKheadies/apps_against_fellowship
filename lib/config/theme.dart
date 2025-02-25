import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// // TBD
// Color neutral100 = const Color(0xFF1e1e1f);
const primary = Color(0xFFAB47BC);
const primaryDark = Color(0xFF790e8b);
const primaryLight = Color(0xFFdf78ef);
// const primaryVariant = Color(0xFFdf78ef);

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

const black = Color(0xFF3C3C3C);
const blackNight = Color(0xFF303030);
const blackUltimate = Color(0xFF000000);

const white = Color(0xFFF2F2F2);
const whiteBright = Color(0xFFFCFCFC);
const whiteUltimate = Color(0xFFFFFFFF);

ThemeData lightTheme() {
  return ThemeData.light().copyWith(
    appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(
        color: primary,
      ),
      backgroundColor: white,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: white,
    ),
    // dividerColor: Colors.red,
    canvasColor: white,
    cardColor: whiteBright,
    colorScheme: const ColorScheme.light().copyWith(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: primaryDark,
      primaryContainer: primaryLight,
      error: error,
      surface: black,
      onSurface: blackNight,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
    ),
    iconTheme: const IconThemeData(
      color: primary,
    ),
    primaryColor: primary,
    scaffoldBackgroundColor: whiteBright,
    snackBarTheme: SnackBarThemeData(
      actionTextColor: primary,
      backgroundColor: black,
      contentTextStyle: Typography.material2018(platform: defaultTargetPlatform)
          .englishLike
          .titleMedium!
          .copyWith(
            color: white,
          ),
    ),
    textTheme: Typography.material2018(platform: defaultTargetPlatform).white,
  );
}

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(
        color: primaryLight,
      ),
      backgroundColor: black,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: black,
    ),
    canvasColor: black,
    cardColor: blackNight,
    colorScheme: const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: primary,
      primaryContainer: primaryDark,
      error: error,
      surface: white,
      onSurface: whiteBright,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
    ),
    iconTheme: const IconThemeData(
      color: primaryLight,
    ),
    primaryColor: primaryLight,
    scaffoldBackgroundColor: blackNight,
    snackBarTheme: SnackBarThemeData(
      actionTextColor: primaryLight,
      backgroundColor: white,
      contentTextStyle: Typography.material2018(platform: defaultTargetPlatform)
          .englishLike
          .titleMedium!
          .copyWith(
            color: black,
          ),
    ),
    textTheme: Typography.material2018(platform: defaultTargetPlatform).black,
  );
}

extension TextAppearanceExt on BuildContext {
  TextStyle cardTextStyle(Color textColor) {
    final base = Theme.of(this).textTheme.headlineSmall;
    final screenWidth = MediaQuery.of(this).size.width;

    double? fontSize = base!.fontSize;
    if (screenWidth > 360 && screenWidth <= 400) {
      fontSize = 20.0; // headline6
    } else if (screenWidth > 300 && screenWidth <= 360) {
      fontSize = 18.0; // subtitle1
    } else if (screenWidth <= 300) {
      fontSize = 16.0;
    }

    return base.copyWith(
      color: textColor,
      fontSize: fontSize,
    );
  }
}
