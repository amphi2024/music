
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/image/album_cover.dart';

import '../../models/music/album.dart';

class PlaylistThumbnail extends StatelessWidget {
  final Playlist playlist;
  final BoxFit? fit;

  const PlaylistThumbnail({super.key, required this.playlist, this.fit});

  @override
  Widget build(BuildContext context) {

    if(playlist.thumbnailData.length > 3) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          var id = playlist.songs[playlist.thumbnailData[index]];
          return AlbumCover(album: appStorage.songs.get(id).album);
        },
      );
    }
    else {
      return AlbumCover(album: Album());
    }
  }
}
