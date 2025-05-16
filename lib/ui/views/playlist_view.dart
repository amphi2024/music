import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';

class PlaylistView extends StatelessWidget {

  final Playlist playlist;
  const PlaylistView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {

    var imageSize = MediaQuery.of(context).size.width - 100;
    final List<Widget> children = [];
    for(var id in playlist.songs) {
      var song = appStorage.songs.get(id);
      children.add( SongListItem(song: song, playlistId: playlist.id) );
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
