import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';

class SongDetailDialog extends StatelessWidget {

  final Song song;
  const SongDetailDialog({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 500,
        child: ListView(
          children: [
            //TODO: implement
          ],
        ),
      ),
    );
  }
}
