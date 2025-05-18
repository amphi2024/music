import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/image/album_cover.dart';

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
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(album.title.byContext(context), style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  )),
                  Text(album.artist.name.byContext(context)),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  children: [
                    _CustomButton(icon: Icons.play_arrow, onPressed: () {
                      if(album.songs.isNotEmpty) {
                        appState.setState(() {
                          var id = album.songs[0];
                          var song = appStorage.songs.get(id);
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}");
                          if(playerService.shuffled) {
                            playerService.toggleShuffle();
                          }
                        });
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: _CustomButton(icon: Icons.shuffle, onPressed: () {
                        if(album.songs.isNotEmpty) {
                          var id = album.songs[0];
                          var song = appStorage.songs.get(id);
                          appState.setState(() {
                            playerService.isPlaying = true;
                            playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}");
                            if(!playerService.shuffled) {
                              playerService.toggleShuffle();
                            }
                          });
                        }
                      }),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _CustomButton extends StatelessWidget {

  final IconData icon;
  final void Function() onPressed;
  const _CustomButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                shape: const CircleBorder()),
            onPressed: onPressed,
            icon: Icon(
              color: Theme.of(context).floatingActionButtonTheme.focusColor,
              icon,
            )));
  }
}
