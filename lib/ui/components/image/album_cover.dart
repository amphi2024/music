import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/music/album.dart';
import 'package:music/utils/media_file_path.dart';

class AlbumCover extends StatelessWidget {

  final Album album;
  final BoxFit? fit;
  const AlbumCover({super.key, required this.album, this.fit});

  @override
  Widget build(BuildContext context) {
    final cover = album.covers.firstOrNull;
    if(cover != null) {
      return AbsoluteAlbumCover(filePath: albumCoverPath(album.id, cover["filename"]), fit: fit);
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
    final file = File(filePath);
    return Image.file(
      file,
      fit: fit,
    );
  }
}
