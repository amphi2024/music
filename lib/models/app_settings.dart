
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:music/models/app_storage.dart';
import 'package:music/models/app_theme.dart';

final appSettings = AppSettings.getInstance();

class AppSettings {
  static final AppSettings _instance = AppSettings();
  static AppSettings getInstance() => _instance;

  Map<String, dynamic> data = {
    "locale": null
  };
  set localeCode(value) => data["locale"] = value;
  String? get localeCode => data["locale"];
  Locale? locale;
  AppTheme appTheme = AppTheme(created: DateTime.now(), modified: DateTime.now());
  String get serverAddress => data.putIfAbsent("serverAddress", () => "");
  bool get transparentNavigationBar => data.putIfAbsent("transparentNavigationBar", () => false);

  void getData() {
    try {
      var file = File(appStorage.settingsPath);
      data = jsonDecode(file.readAsStringSync());
      locale = Locale(appSettings.localeCode ?? PlatformDispatcher.instance.locale.languageCode);
    }
    catch(e) {
      save();
    }
  }

  void save() {
    var file = File(appStorage.settingsPath);
    file.writeAsString(jsonEncode(data));
  }

}