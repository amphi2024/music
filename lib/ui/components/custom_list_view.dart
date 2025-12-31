import 'dart:io';

import 'package:flutter/cupertino.dart';

class CustomListView extends StatelessWidget {
  final ScrollController? controller;
  final EdgeInsets? padding;
  final int itemCount;
  final Widget? Function(BuildContext context, int index) itemBuilder;
  const CustomListView({super.key, this.controller, this.padding, required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      padding: padding,
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    if(Platform.isAndroid || Platform.isIOS) {
      return CupertinoScrollbar(
          controller: controller,
          child: listView);
    }

    return listView;
  }
}
