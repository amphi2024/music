import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amphi/models/app.dart';

import 'app_theme.dart';
class AppThemeData {
  Color backgroundColor;
  Color textColor;
  Color accentColor;
  Color inactiveColor;
  Color floatingButtonBackground;
  Color floatingButtonIconColor;
  Color checkBoxColor;
  Color checkBoxCheckColor;
  Color errorColor;
  Color navigationBarBackgroundColor;
  Color cardBackgroundColor;

  AppThemeData({
    this.backgroundColor = AppTheme.midnight,
    this.textColor = AppTheme.white,
    this.accentColor = AppTheme.cherry,
    this.inactiveColor = AppTheme.inactiveGray,
    this.floatingButtonBackground = AppTheme.white,
    this.floatingButtonIconColor = AppTheme.lightBlue,
    this.checkBoxColor = AppTheme.lightBlue,
    this.checkBoxCheckColor = AppTheme.white,
    this.errorColor = AppTheme.red,
    this.navigationBarBackgroundColor = AppTheme.charCoal,
    this.cardBackgroundColor = AppTheme.charCoal
  });

  ThemeData themeData({required Brightness brightness, required BuildContext context}) {

    var isWideScreen = App.isWideScreen(context);

    return ThemeData(
      brightness: brightness,
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: inactiveColor, fontSize: 15),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: accentColor, style: BorderStyle.solid, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: backgroundColor, style: BorderStyle.solid))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              elevation: 0,
              padding: const EdgeInsets.only(left: 10, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              textStyle: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))),
      // scrollbarTheme: ScrollbarThemeData(
      //   trackColor: WidgetStateColor.transparent,
      //   thumbColor: WidgetStatePropertyAll(
      //     Colors.red
      //   )
      // ),
      sliderTheme: SliderThemeData(
         disabledActiveTrackColor: accentColor,
        trackHeight: 5,
        inactiveTrackColor: inactiveColor,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
          overlayShape: SliderComponentShape.noOverlay
      ),
      dividerColor: inactiveColor,
      dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(
              color: textColor, fontSize: 15
          )
      ),
      popupMenuTheme: PopupMenuThemeData(
          surfaceTintColor: backgroundColor,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
      iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
              surfaceTintColor: WidgetStateProperty.all(backgroundColor))),
      shadowColor:
      backgroundColor.green + backgroundColor.blue + backgroundColor.red >
          381
          ? Colors.grey.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.5),
      iconTheme: IconThemeData(color: accentColor, size: 20),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return checkBoxCheckColor;
          } else {
            return AppTheme.transparent;
          }
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return checkBoxColor;
          } else {
            return AppTheme.transparent;
          }
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor.withAlpha(245),
          surfaceTintColor: backgroundColor.withAlpha(245),
          toolbarHeight: 40,
          titleSpacing: 0.0,
          iconTheme: IconThemeData(color: accentColor, size: 20)),
      disabledColor: inactiveColor,
      highlightColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardBackgroundColor,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBarBackgroundColor
      ),
      snackBarTheme: SnackBarThemeData(
          backgroundColor: floatingButtonBackground,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.vertical,
          contentTextStyle: TextStyle(
              color: floatingButtonIconColor
          )
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accentColor,
        onPrimary: textColor,
        secondary: accentColor,
        onSecondary: textColor,
        onError: accentColor,
        error: AppTheme.red,
        surface: backgroundColor,
        onSurface: textColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: floatingButtonBackground,
          focusColor: floatingButtonIconColor,
          iconSize: 35),
      textTheme: TextTheme(
          bodyLarge: TextStyle(
              color: textColor, fontSize: 20, overflow: TextOverflow.ellipsis),
        bodyMedium: TextStyle(
            color: textColor, fontSize: 15, overflow: TextOverflow.ellipsis),
        titleMedium: TextStyle(
            color: textColor, fontSize: 15, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: textColor, fontSize: isWideScreen ? 20 : 25, overflow: TextOverflow.ellipsis
        )
      ),
      dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
          titleTextStyle: TextStyle(
              color: textColor, fontSize: 17.5, fontWeight: FontWeight.bold)),
      navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: Color.fromARGB(
              backgroundColor.alpha,
              backgroundColor.red - 10,
              backgroundColor.green - 10,
              backgroundColor.blue - 10)),
    );
  }
}