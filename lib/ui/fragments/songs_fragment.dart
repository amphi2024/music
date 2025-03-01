import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../models/music/music.dart';

class SongsFragment extends StatefulWidget {
  const SongsFragment({super.key});

  @override
  State<SongsFragment> createState() => _SongsFragmentState();
}

class _SongsFragmentState extends State<SongsFragment> {

  @override
  Widget build(BuildContext context) {
    List<Music> musicList = [];
    List<Widget> children = [];
    appStorage.music.forEach((key, music) {
      musicList.add(music);
    });
    children.add(Container(
      height: 60,
    ));
    for (int i = 0; i < musicList.length; i++) {
      var music = musicList[i];
      var musicWidget = GestureDetector(
        onTap: () {
         playerService.startPlay(music: music, i: i);
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SizedBox(
                  width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AlbumCover(
                          album: music.album,

                      ),
                    )
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          music.title["default"] ?? "unknown",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: playerService.nowPlaying().id == music.id ? Theme.of(context).highlightColor : null
                        ),
                      ),
                      Text(
                        music.artist.name["default"] ?? "unknown",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: playerService.nowPlaying().id == music.id ? Theme.of(context).highlightColor : null
                        ),
                      )
                    ],
                  )
              ),
              Icon(
                  Icons.arrow_downward_outlined,
                size: 13,
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
            ],
          ),
        ),
      );
      children.add(musicWidget);
    }
    return ListView(
      children: children,
    );
  }
}
