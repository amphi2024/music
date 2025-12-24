import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/genres_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/songs_provider.dart';
import '../../services/player_service.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class GenreFragment extends ConsumerWidget {
  const GenreFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreId = ref
        .watch(showingPlaylistIdProvider)
        .split(",")
        .last;
    final genres = ref.watch(genresProvider);
    final genre = genres[genreId] ?? {};
    final playlist = showingPlaylist(ref);
    final idList = playlist.songs;
    final songs = ref.watch(songsProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      itemCount: idList.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 5),
            child: Text(genre.byContext(context), style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
            ),),
          );
        }
        else if (index == 1) {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
                  if (playlist.songs.isNotEmpty) {
                    final song = ref.read(songsProvider).get(playlist.songs[0]);
                    playerService.startPlay(song: song, playlistId: playlist.id, ref: ref, shuffle: false);
                  }
                }),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 15),
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
          );
        }
        else {
          final id = idList[index - 2];
          final song = songs.get(id);
          return SongListItem(song: song, playlistId: playlist.id);
        }
      },
    );
  }
}
