import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:amphi/models/app_theme_core.dart';
import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme extends AppThemeCore {
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightGray = Color.fromRGBO(245, 245, 245, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color lightBlue = Color.fromRGBO(0, 140, 255, 1.0);
  static const Color cherry = Color.fromRGBO(255, 16, 80, 1.0);
  static const Color skyBlue = Color.fromRGBO(70, 180, 255, 1.0);
  static const Color midnight = Color.fromRGBO(35, 35, 35, 1.0);
  static const Color inactiveGray = Color(0xFF999999);
  static const Color yellow = Color(0xFFFFF176);
  static const Color charCoal = Color.fromRGBO(45, 45, 45, 1.0);
  static const Color transparent =Color(0x00000000);
  static const Color red =Color(0xFFFF1F24);

  LightTheme lightTheme = LightTheme();
  DarkTheme darkTheme = DarkTheme();

  AppTheme(
      {
        super.title = "",
        super.filename = "!DEFAULT",
        required super.created,
        required super.modified,
        super.path = ""
      });

  static AppTheme fromFile(File file) {

    String jsonString = file.readAsStringSync();
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    AppTheme appTheme = AppTheme(
        created: DateTime.fromMillisecondsSinceEpoch(jsonData["created"]).toLocal(),
        modified: DateTime.fromMillisecondsSinceEpoch(jsonData["modified"]).toLocal(),
        path: file.path,
        filename: file.path
            .split("/")
            .last
    );
    appTheme.title = jsonData["title"];

    appTheme.lightTheme.backgroundColor =
        Color(jsonData["lightBackgroundColor"]);
    appTheme.lightTheme.textColor = Color(jsonData["lightTextColor"]);
    appTheme.lightTheme.accentColor = Color(jsonData["lightAccentColor"]);
    appTheme.lightTheme.inactiveColor = Color(jsonData["lightInactiveColor"]);
    appTheme.lightTheme.floatingButtonBackground =
        Color(jsonData["lightFloatingButtonBackground"]);
    appTheme.lightTheme.floatingButtonIconColor =
        Color(jsonData["lightFloatingButtonIconColor"]);
    appTheme.lightTheme.checkBoxColor = Color(jsonData["lightCheckBoxColor"]);
    appTheme.lightTheme.checkBoxCheckColor =
        Color(jsonData["lightCheckBoxCheckColor"]);

    appTheme.darkTheme.backgroundColor =
        Color(jsonData["darkBackgroundColor"]);
    appTheme.darkTheme.textColor = Color(jsonData["darkTextColor"]);
    appTheme.darkTheme.accentColor = Color(jsonData["darkAccentColor"]);
    appTheme.darkTheme.inactiveColor = Color(jsonData["darkInactiveColor"]);
    appTheme.darkTheme.floatingButtonBackground =
        Color(jsonData["darkFloatingButtonBackground"]);
    appTheme.darkTheme.floatingButtonIconColor =
        Color(jsonData["darkFloatingButtonIconColor"]);
    appTheme.darkTheme.checkBoxColor = Color(jsonData["darkCheckBoxColor"]);
    appTheme.darkTheme.checkBoxCheckColor =
        Color(jsonData["darkCheckBoxCheckColor"]);

    return appTheme;
  }

  Future<void> save({bool upload = true}) async {
    await saveFile((fileContent) {
      if(upload) {
      //  appWebChannel.uploadTheme(themeFileContent: fileContent, themeFilename: filename);
      }
    });
  }

  Future<void> delete({bool upload = true}) async {
    await super.deleteFile();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,

      "lightBackgroundColor": lightTheme.backgroundColor.value,
      "lightTextColor":  lightTheme.textColor.value,
      "lightAccentColor":  lightTheme.accentColor.value,
      "lightInactiveColor":  lightTheme.inactiveColor.value,
      "lightFloatingButtonBackground":  lightTheme.floatingButtonBackground.value,
      "lightFloatingButtonIconColor":  lightTheme.floatingButtonIconColor.value,
      "lightCheckBoxColor":  lightTheme.checkBoxColor.value,
      "lightCheckBoxCheckColor":  lightTheme.checkBoxCheckColor.value,

      "darkBackgroundColor": darkTheme.backgroundColor.value,
      "darkTextColor":  darkTheme.textColor.value,
      "darkAccentColor":  darkTheme.accentColor.value,
      "darkInactiveColor":  darkTheme.inactiveColor.value,
      "darkFloatingButtonBackground":  darkTheme.floatingButtonBackground.value,
      "darkFloatingButtonIconColor":  darkTheme.floatingButtonIconColor.value,
      "darkCheckBoxColor":  darkTheme.checkBoxColor.value,
      "darkCheckBoxCheckColor":  darkTheme.checkBoxCheckColor.value,
    };
  }
}