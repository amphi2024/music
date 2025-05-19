import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/fragments/components/floating_button.dart';

import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';

class GenreView extends StatefulWidget {
  final Map<String, dynamic> genre;

  const GenreView({super.key, required this.genre});

  @override
  State<GenreView> createState() => _GenreViewState();
}

class _GenreViewState extends State<GenreView> {
  @override
  Widget build(BuildContext context) {
    List<Song> songList = [];
    var genreName = widget.genre["default"];
    final playlistId = "!GENRE,${genreName}";
    appStorage.songs.forEach((key, song) {
      for (var genre in song.genre) {
        if (genre is Map<String, dynamic> && genre.containsValue(genreName)) {
          songList.add(song);
        }
      }
    });

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: GestureDetector(
              onLongPress: () {},
              child: Text(
                widget.genre.byContext(context),
                style: TextStyle(fontSize: 20),
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FloatingButton(icon: Icons.play_arrow, onPressed: () {
                  var song = songList.firstOrNull;
                  if(song != null) {
                    appState.setState(() {
                      playerService.isPlaying = true;
                      playerService.shuffled = false;
                      playerService.startPlay(song: song, playlistId: playlistId);
                    });
                  }
                }),
                Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                      var song = songList.firstOrNull;
                      if(song != null) {
                        appState.setState(() {
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: playlistId, shuffle: true);
                        });
                      }
                }))
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            var song = songList[index];
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
                  )),
            );
            return SongListItem(song: song, playlistId: playlistId, albumCover: albumCover);
          },
               childCount: songList.length),
        ),
      ]),
    );
  }
}
