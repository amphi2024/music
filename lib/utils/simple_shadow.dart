import 'package:flutter/material.dart';

List<BoxShadow> simpleShadow(BuildContext context) {
  return [
    BoxShadow(
      color: Theme.of(context).shadowColor,
      spreadRadius: 3,
      blurRadius: 5,
      offset: const Offset(0, 3),
    )
  ];
}