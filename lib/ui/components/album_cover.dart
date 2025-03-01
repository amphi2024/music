import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/music/album.dart';

class AlbumCover extends StatelessWidget {

  final Album album;
  final BoxFit? fit;
  const AlbumCover({super.key, required this.album, this.fit});

  @override
  Widget build(BuildContext context) {
    var coverFilePath = album.covers.firstOrNull;
    if(coverFilePath != null) {
      var file = File(coverFilePath);
      if(!file.existsSync()) {
        return Image.asset("assets/images/music.png", fit: fit);
      }
      return Image.file(
          file,
        fit: fit,
      );
    }
    else {
      return Image.asset("assets/images/music.png", fit: fit);
    }
  }
}
