import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';
import 'package:music/ui/components/playing/play_controls.dart';

import 'desktop_play_controls.dart';

class DesktopPlayingBar extends StatefulWidget {
  const DesktopPlayingBar({super.key});

  @override
  State<DesktopPlayingBar> createState() => _DesktopPlayingBarState();
}

class _DesktopPlayingBarState extends State<DesktopPlayingBar> {

  double length = 10;
  double position = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 200,
        right: 0,
        bottom: 0,
        child: Container(
          height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],

      ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: AlbumCover(album: playerService.nowPlaying().album))),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(playerService.nowPlaying().title.byLocale(context)),
                      Text(playerService.nowPlaying().artist.name.byLocale(context))
                    ],
                  )
                ],
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: 200
                  ),
                  child: DesktopPlayControls(
                    length: length,
                    position: position,
                    setState: setState,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // PopupMenuButton(icon: Icon(Icons.add_circle_outline),
                  //     itemBuilder: (context) {
                  //   return [
                  //     PopupMenuItem(child: Text("Song"), onTap: () {}),
                  //     PopupMenuItem(child: Text("Playlist"), onTap: () {}),
                  //   ];
                  // }),
                  IconButton(onPressed: () {}, icon: Icon(Icons.lyrics)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.list)),
                ],
              ),
            ],
          ),
    )
    );
  }
}
