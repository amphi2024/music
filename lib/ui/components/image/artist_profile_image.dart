import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/music/artist.dart';

class ArtistProfileImage extends StatelessWidget {

  final Artist artist;
  final BoxFit? fit;
  const ArtistProfileImage({super.key, required this.artist, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    var filePath = artist.profileImages.firstOrNull;
    if(filePath != null) {
      return AbsoluteArtistProfileImage(filePath: filePath);
    }
    else {
      artist.downloadMissingFiles();
      return Image.asset("assets/images/music.png", fit: fit);
    }
  }
}

class AbsoluteArtistProfileImage extends StatelessWidget {

  final String filePath;
  final BoxFit? fit;
  const AbsoluteArtistProfileImage({super.key, required this.filePath, this.fit = BoxFit.cover});

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