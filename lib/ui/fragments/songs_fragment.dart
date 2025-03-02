
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/music_list_item.dart';

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
      children.add(MusicListItem(music: music, index: i));
    }
    return ListView(
      children: children,
    );
  }
}
