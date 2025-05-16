import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/image/album_cover.dart';

import '../../models/music/album.dart';

class PlaylistThumbnail extends StatefulWidget {
  final Playlist playlist;
  final BoxFit? fit;

  const PlaylistThumbnail({super.key, required this.playlist, this.fit});

  @override
  State<PlaylistThumbnail> createState() => _PlaylistThumbnailState();
}

class _PlaylistThumbnailState extends State<PlaylistThumbnail> {
  final List<int> indexList = [];

  @override
  void initState() {
    if(widget.playlist.songs.length > 3) {
      for (int i = 0; i < 4; i++) {
        int index = Random().nextInt(widget.playlist.songs.length);
        if (indexList.contains(index)) {
          i--;
        }
        else {
          indexList.add(index);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.playlist.songs.length > 3) {
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
          var id = widget.playlist.songs[indexList[index]];
          return AlbumCover(album: appStorage.songs.get(id).album);
        },
      );
    }
    else {
      return AlbumCover(album: Album());
    }
  }
}
