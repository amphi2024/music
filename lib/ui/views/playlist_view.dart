import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';

import '../../models/app_state.dart';
import '../../models/player_service.dart';
import '../components/image/album_cover.dart';
import '../fragments/components/floating_button.dart';

class PlaylistView extends StatelessWidget {

  final Playlist playlist;
  const PlaylistView({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {

    var imageSize = MediaQuery.of(context).size.width - 100;

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 15), child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
                      if(playlist.songs.isNotEmpty) {
                        appState.setState(() {
                          var id = playlist.songs[0];
                          var song = appStorage.songs.get(id);
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: playlist.id);
                          playerService.shuffled = false;
                        });
                      }
                    })),
                    FloatingButton(icon: Icons.shuffle, onPressed: () {
                      if(playlist.songs.isNotEmpty) {
                        var index = Random().nextInt(playlist.songs.length);
                        var id = playlist.songs[index];
                        var song = appStorage.songs.get(id);
                        appState.setState(() {
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: playlist.id, shuffle: true);
                        });
                      }
                    })
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var id = playlist.songs[index];
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
                    return SongListItem(song: song, playlistId: playlist.id, albumCover: albumCover);
                  },
                  childCount: playlist.songs.length
                  ),
              ),
            )
          ]
      ),
    );
  }
}
