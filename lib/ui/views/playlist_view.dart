import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';

import '../components/image/album_cover.dart';

class PlaylistView extends StatelessWidget {

  final Playlist playlist;
  const PlaylistView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {

    var imageSize = MediaQuery.of(context).size.width - 100;
    final List<Widget> children = [];
    for(var id in playlist.songs) {
      var song = appStorage.songs.get(id);
      var albumCover = Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AlbumCover(
                album: song.album,
              ),
            )
        ),
      );
      children.add( SongListItem(song: song, playlistId: playlist.id, albumCover: albumCover) );
    }
    children.add(SizedBox(height: 80));

    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width + 80,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
                  onLongPress: () {

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      playlist.title,
                      style: TextStyle(
                          fontSize: 15
                      ),
                    ),
                  ),
                ),
                centerTitle: true,
                background: Center(
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: PlaylistThumbnail(playlist: playlist)),
                  ),
                ),
              ),
            ),
            SliverList.list(
                children: children
            )
          ]
      ),
    );
  }
}
