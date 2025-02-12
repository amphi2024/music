
import 'dart:io';

import 'package:music/models/app_storage.dart';

final appSettings = AppSettings.getInstance();

class AppSettings {
  static final AppSettings _instance = AppSettings();
  static AppSettings getInstance() => _instance;

  void getData() async {
    var file = File(appStorage.settingsPath);
  }

}