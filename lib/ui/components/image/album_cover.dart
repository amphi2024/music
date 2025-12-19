import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/music/album.dart';
import 'package:music/utils/media_file_path.dart';

class AlbumCover extends StatelessWidget {

  final Album album;
  final BoxFit? fit;
  const AlbumCover({super.key, required this.album, this.fit});

  @override
  Widget build(BuildContext context) {
    final cover = album.covers.elementAtOrNull(album.coverIndex ?? 0);
    if(cover != null) {
      return AbsoluteAlbumCover(filePath: albumCoverPath(album.id, cover["filename"]), fit: fit,
          errorBuilder: (context, error, stackTrace) {
            if(appSettings.useOwnServer) {
              appWebChannel.downloadAlbumCover(albumId: album.id, filename: cover["filename"]);
              return Image(image: NetworkImage("${appSettings.serverAddress}/music/albums/${album.id}/covers/${cover["filename"]}", headers: {
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

class AbsoluteAlbumCover extends StatelessWidget {

  final String filePath;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  const AbsoluteAlbumCover({super.key, required this.filePath, this.fit, this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    return Image.file(
      file,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
