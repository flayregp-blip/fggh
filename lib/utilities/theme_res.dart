import 'package:flutter/material.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/font_res.dart';

class ThemeRes {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: ColorRes.whitePure,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: ColorRes.whitePure),
      appBarTheme: const AppBarTheme(backgroundColor: ColorRes.bgLightGrey),
      fontFamily: FontRes.outFitRegular400,
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: ColorRes.whitePure),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorRes.whitePure),
        titleMedium: TextStyle(color: ColorRes.textDarkGrey),
        titleSmall: TextStyle(color: ColorRes.textLightGrey),
        labelSmall: TextStyle(color: ColorRes.themeAccentSolid),
        labelLarge: TextStyle(color: ColorRes.disabledGrey),
      ),
      textSelectionTheme: const TextSelectionThemeData(selectionColor: ColorRes.disabledGrey),
      cardTheme: const CardThemeData(color: ColorRes.blueFollow),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: ColorRes.themeAccentSolid,
      dividerColor: ColorRes.bgGrey,
      cardColor: ColorRes.bgMediumGrey,
      primaryColorDark: ColorRes.blackPure,
      canvasColor: ColorRes.themeColor,
      useMaterial3: false,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData();
  }
}

// Helper functions - all properly defined
Color whitePure(BuildContext context) => Theme.of(context).textTheme.titleLarge?.color ?? ColorRes.whitePure;
Color textDarkGrey(BuildContext context) => Theme.of(context).textTheme.titleMedium?.color ?? ColorRes.textDarkGrey;
Color textLightGrey(BuildContext context) => Theme.of(context).textTheme.titleSmall?.color ?? ColorRes.textLightGrey;
Color bgGrey(BuildContext context) => Theme.of(context).dividerColor ?? ColorRes.bgGrey;
Color themeAccentSolid(BuildContext context) => Theme.of(context).textTheme.labelSmall?.color ?? ColorRes.themeAccentSolid;
Color disableGrey(BuildContext context) => Theme.of(context).textTheme.labelLarge?.color ?? ColorRes.disabledGrey;
Color scaffoldBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor ?? ColorRes.whitePure;
Color blueFollow(BuildContext context) => Theme.of(context).cardTheme.color ?? ColorRes.blueFollow;
Color bgMediumGrey(BuildContext context) => Theme.of(context).cardColor ?? ColorRes.bgMediumGrey;
Color blackPure(BuildContext context) => Theme.of(context).primaryColorDark ?? ColorRes.blackPure;
Color bgLightGrey(BuildContext context) => Theme.of(context).appBarTheme.backgroundColor ?? ColorRes.bgLightGrey;
Color themeColor(BuildContext context) => Theme.of(context).canvasColor ?? ColorRes.themeColor;
