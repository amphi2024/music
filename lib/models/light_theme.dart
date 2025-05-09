import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_theme_data.dart';

class LightTheme extends AppThemeData {

  LightTheme(
      {
        super.backgroundColor = const Color.fromARGB(255, 250, 250, 250),
        super.textColor = AppTheme.midnight,
        super.accentColor = AppTheme.cherry,
        super.inactiveColor = AppTheme.inactiveGray,
        super.floatingButtonBackground = AppTheme.white,
        super.floatingButtonIconColor = AppTheme.cherry,
        super.checkBoxColor = AppTheme.cherry,
        super.checkBoxCheckColor = AppTheme.white,
        super.errorColor = AppTheme.red,
        super.navigationBarBackgroundColor = AppTheme.lightGray,
        super.cardBackgroundColor = AppTheme.white
      });
  ThemeData toThemeData(BuildContext context) {
    return themeData(
        brightness: Brightness.light, context: context);
  }
}