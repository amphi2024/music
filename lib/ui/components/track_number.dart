import 'package:flutter/material.dart';

class TrackNumber extends StatelessWidget {

  final int trackNumber;
  const TrackNumber({super.key, required this.trackNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: 20, right: 20), child: Text(trackNumber.toString()));
  }
}