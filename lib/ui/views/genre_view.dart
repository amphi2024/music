import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/songs_provider.dart';
import '../components/item/song_list_item.dart';

class GenreView extends ConsumerWidget {
  final Map<String, dynamic> genre;

  const GenreView({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreName = genre["default"];
    final playlistId = "!GENRE,${genreName}";
    final genrePlaylist = ref.watch(playlistsProvider).playlists.get(playlistId);
    final songs = ref.watch(songsProvider);

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 100,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: GestureDetector(
              onLongPress: () {},
              child: Text(
                genre.byContext(context),
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
                FloatingButton(
                    icon: Icons.play_arrow,
                    onPressed: () {
                      // var song = songList.firstOrNull;
                      // if (song != null) {
                      //   // appState.setState(() {
                      //   //   playerService.isPlaying = true;
                      //   //   playerService.shuffled = false;
                      //   //   playerService.startPlay(song: song, playlistId: playlistId);
                      //   // });
                      // }
                    }),
                Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: FloatingButton(
                        icon: Icons.shuffle,
                        onPressed: () {
                          // var song = songList.firstOrNull;
                          // if (song != null) {
                          //   // appState.setState(() {
                          //   //   playerService.isPlaying = true;
                          //   //   playerService.startPlay(song: song, playlistId: playlistId, shuffle: true);
                          //   // });
                          // }
                        }))
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final songId = genrePlaylist.songs[index];
            final song = songs.get(songId);
            return SongListItem(song: song, playlistId: playlistId);
          }, childCount: genrePlaylist.songs.length),
        ),
      ]),
    );
  }
}
