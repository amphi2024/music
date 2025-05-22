import 'package:flutter/widgets.dart';

EdgeInsets fragmentPadding(BuildContext context) {
  final padding = MediaQuery.paddingOf(context);
  return EdgeInsets.only(top: 50 + padding.top, bottom: 80 + padding.bottom);
}