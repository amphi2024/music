import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';

extension LocalizedTitle on Map<String, dynamic> {
  String byContext(BuildContext context) {
    return byLocaleCode(Localizations.localeOf(context).languageCode);
  }

  String byLocaleCode(String code) {
    String value = this[code] ?? this["default"] ?? "";
    if(value.isNotEmpty) {
      return value;
    }
    else {
      return "";
    }
  }

  String toLocalized() {
    return byLocaleCode(appSettings.localeCode ?? "default");
  }
}