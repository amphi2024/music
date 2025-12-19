import 'package:flutter/widgets.dart';
import 'package:music/utils/screen_size.dart';

EdgeInsets fragmentPadding(BuildContext context) {
  if(isDesktopOrTablet(context)) {
    return EdgeInsets.zero;
  }
  final padding = MediaQuery.paddingOf(context);
  return EdgeInsets.only(top: 55 + padding.top, bottom: 100 + padding.bottom);
}