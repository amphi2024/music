import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/ui/fragments/components/floating_button.dart';

import '../../dialogs/edit_album_dialog.dart';

class AlbumFragmentTitle extends StatelessWidget {

  final Album album;
  const AlbumFragmentTitle({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AlbumCover(album: album),
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
                        showDialog(context: context, builder: (context) => EditAlbumDialog(album: album, onSave: (a) {
                          appState.setFragmentState(() {

                          });
                        }));
                      },
                      child: Text(album.title.byContext(context), style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                      )),
                    ),
                    Text(album.artist.name.byContext(context)),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FloatingButton(icon: Icons.play_arrow, onPressed: () {
                            if(album.songs.isNotEmpty) {
                              appState.setState(() {
                                var id = album.songs[0];
                                var song = appStorage.songs.get(id);
                                playerService.isPlaying = true;
                                playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}");
                                playerService.shuffled = false;
                              });
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                              if(album.songs.isNotEmpty) {
                                int index = Random().nextInt(album.songs.length);
                                var id = album.songs[index];
                                var song = appStorage.songs.get(id);
                                appState.setState(() {
                                  playerService.isPlaying = true;
                                  playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}", shuffle: true);
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