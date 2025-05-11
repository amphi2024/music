import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/album.dart';

class AlbumCover extends StatelessWidget {

  final Album album;
  final BoxFit? fit;
  const AlbumCover({super.key, required this.album, this.fit});

  @override
  Widget build(BuildContext context) {
    var coverFilePath = album.covers.firstOrNull;
    if(coverFilePath != null) {
      return AbsoluteAlbumCover(filePath: coverFilePath, fit: fit);
    }
    else {
      return Image.asset("assets/images/music.png", fit: fit);
    }
  }
}

class AbsoluteAlbumCover extends StatelessWidget {

  final String filePath;
  final BoxFit? fit;
  const AbsoluteAlbumCover({super.key, required this.filePath, this.fit});

  @override
  Widget build(BuildContext context) {
    var file = File(filePath);
    if(!file.existsSync()) {
      return Image.asset("assets/images/music.png", fit: fit);
    }
    return Image.file(
      file,
      fit: fit,
    );
  }
}
