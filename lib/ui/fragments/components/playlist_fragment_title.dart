import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';
import 'package:music/ui/dialogs/edit_playlist_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';


class PlaylistFragmentTitle extends StatelessWidget {

  final Playlist playlist;
  const PlaylistFragmentTitle({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {

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
                    showDialog(context: context, builder: (context) => EditPlaylistDialog(
                        playlist: playlist,
                        onSave: (result) {
                          appState.setState(() {

                          });
                        }));
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
                            if(playlist.songs.isNotEmpty) {
                              appState.setState(() {
                                var id = playlist.songs[0];
                                var song = appStorage.songs.get(id);
                                playerService.isPlaying = true;
                                playerService.startPlay(song: song, playlistId: playlist.id);
                                playerService.shuffled = false;
                              });
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                              if(playlist.songs.isNotEmpty) {
                                var id = playlist.songs[0];
                                var song = appStorage.songs.get(id);
                                appState.setState(() {
                                  playerService.isPlaying = true;
                                  playerService.startPlay(song: song, playlistId: playlist.id, shuffle: true);
                                });
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}