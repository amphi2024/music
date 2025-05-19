import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_theme_data.dart';

class DarkTheme extends AppThemeData {

  DarkTheme(
      {
        super.backgroundColor = AppTheme.midnight,
        super.textColor = AppTheme.white,
        //super.accentColor = AppTheme.lightBlue,
        super.accentColor = AppTheme.cherry,
        super.inactiveColor = AppTheme.inactiveGray,
        super.floatingButtonBackground = AppTheme.white,
        super.floatingButtonIconColor = AppTheme.cherry,
        super.checkBoxColor = AppTheme.cherry,
        super.checkBoxCheckColor = AppTheme.white,
        super.errorColor = AppTheme.red
      });

  ThemeData toThemeData(BuildContext context) {
    return themeData(
        brightness: Brightness.dark, context: context);
  }
}