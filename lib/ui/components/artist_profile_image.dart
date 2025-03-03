import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/music/artist.dart';

class ArtistProfileImage extends StatelessWidget {

  final Artist artist;
  final BoxFit? fit;
  const ArtistProfileImage({super.key, required this.artist, this.fit});

  @override
  Widget build(BuildContext context) {
    var filePath = artist.profileImages.firstOrNull;
    if(filePath != null) {
      var file = File(filePath);
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
