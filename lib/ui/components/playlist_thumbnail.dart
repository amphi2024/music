import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/image/album_cover.dart';

import '../../models/music/album.dart';

class PlaylistThumbnail extends ConsumerWidget {
  final Playlist playlist;
  final BoxFit? fit;

  const PlaylistThumbnail({super.key, required this.playlist, this.fit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);
    final albums = ref.watch(albumsProvider);
    if (playlist.thumbnailIndexes.length > 3) {
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
          final id = playlist.songs[playlist.thumbnailIndexes.elementAt(index)];
          final song = songs.get(id);
          return AlbumCover(album: albums
              .get(song.albumId));
        },
      );
    }
    else {
      return AlbumCover(album: Album(id: ""));
    }
  }
}
