import 'package:flutter/widgets.dart';
import 'package:music/utils/screen_size.dart';

EdgeInsets fragmentPadding(BuildContext context) {
  if(isDesktopOrTablet(context)) {
    return EdgeInsets.zero;
  }
  final padding = MediaQuery.paddingOf(context);

  // Return different bottom padding for iOS-like gestures and Android 3-button-like gestures
  return EdgeInsets.only(top: 55 + padding.top, bottom: padding.bottom + (padding.bottom < 15 ? 80 : 65));
}