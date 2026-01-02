import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/utils/media_file_path.dart';

import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';

class ArtistProfileImage extends StatelessWidget {

  final Artist artist;
  final BoxFit? fit;
  const ArtistProfileImage({super.key, required this.artist, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if(artist.images.isNotEmpty) {
      return AbsoluteArtistProfileImage(
          filePath: artistImagePath(artist.id, artist.images[artist.imageIndex]["filename"]), fit: fit,           errorBuilder: (context, error, stackTrace) {
        if(appSettings.useOwnServer) {
          appWebChannel.downloadArtistImage(artistId: artist.id, filename: artist.images[artist.imageIndex]["filename"]);
          return Image(image: NetworkImage("${appSettings.serverAddress}/music/artists/${artist.id}/images/${artist.images[artist.imageIndex]["filename"]}", headers: {
            "Authorization": appWebChannel.token
          }), errorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/images/music.png", fit: fit);
          });
        }
        return Image.asset("assets/images/music.png", fit: fit);
      });
    }
    else {
      return Image.asset("assets/images/music.png", fit: fit);
    }
  }
}

class AbsoluteArtistProfileImage extends StatelessWidget {

  final String filePath;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  const AbsoluteArtistProfileImage({super.key, required this.filePath, this.fit = BoxFit.cover, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
      var file = File(filePath);
      return Image.file(
        file,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }
}