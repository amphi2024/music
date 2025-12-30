import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/songs_provider.dart';
import '../../services/player_service.dart';
import '../components/item/song_list_item.dart';

class GenrePage extends ConsumerWidget {
  final Map<String, dynamic> genre;

  const GenrePage({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreName = genre["default"];
    final playlistId = "!GENRE,${genreName}";
    final playlist = ref.watch(playlistsProvider).playlists.get(playlistId);
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
                      if (playlist.songs.isNotEmpty) {
                        final song = ref.read(songsProvider).get(playlist.songs[0]);
                        playerService.startPlay(song: song, playlistId: playlist.id, ref: ref, shuffle: false);
                      }
                    }),
                Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: FloatingButton(
                        icon: Icons.shuffle,
                        onPressed: () {
                          if(playlist.songs.isNotEmpty) {
                            final index = Random().nextInt(playlist.songs.length);
                            final song = ref.read(songsProvider).get(playlist.songs[index]);
                            playerService.startPlay(song: song, playlistId: playlist.id, ref: ref, shuffle: true);
                          }
                        }))
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final songId = playlist.songs[index];
            final song = songs.get(songId);
            return SongListItem(song: song, playlistId: playlistId);
          }, childCount: playlist.songs.length),
        ),
      ]),
    );
  }
}
