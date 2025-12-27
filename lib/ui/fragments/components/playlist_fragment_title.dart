import 'dart:math';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';
import 'package:music/ui/dialogs/edit_playlist_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';

import '../../../providers/playlists_provider.dart';
import '../../../providers/songs_provider.dart';
import '../../../services/player_service.dart';

class PlaylistFragmentTitle extends ConsumerWidget {

  final Playlist playlist;

  const PlaylistFragmentTitle({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PlaylistThumbnail(playlist: playlist),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () {
                    showDialog(context: context, builder: (context) =>
                        EditPlaylistDialog(
                            playlist: playlist, ref: ref));
                  },
                  child: Text(playlist.title, style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FloatingButton(icon: Icons.play_arrow, onPressed: () {
                            if (playlist.songs.isNotEmpty) {
                              final song = ref.read(songsProvider).get(playlist.songs[0]);
                              playerService.startPlay(song: song, playlistId: playlist.id, ref: ref, shuffle: false);
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                              if(playlist.songs.isNotEmpty) {
                                final index = Random().nextInt(playlist.songs.length);
                                final song = ref.read(songsProvider).get(playlist.songs[index]);
                                playerService.startPlay(song: song, playlistId: playlist.id, ref: ref, shuffle: true);
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text(AppLocalizations.of(context).get("edit")), onTap: () {
                          showDialog(context: context, builder: (context) =>
                              EditPlaylistDialog(
                                  playlist: playlist, ref: ref));
                        }),
                        PopupMenuItem(child: Text(AppLocalizations.of(context).get("move_to_trash")), onTap: () {
                          showDialog(context: context, builder: (context) {
                            return ConfirmationDialog(
                              title: AppLocalizations.of(context).get("dialog_title_move_to_trash"),
                              onConfirmed: () {
                                playlist.deleted = DateTime.now();
                                playlist.save();
                                ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
                              },
                            );
                          });
                        })
                      ];
                    })
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}