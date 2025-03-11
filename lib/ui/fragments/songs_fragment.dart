
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/song_list_item.dart';

import '../../models/music/song.dart';

class SongsFragment extends StatefulWidget {
  const SongsFragment({super.key});

  @override
  State<SongsFragment> createState() => _SongsFragmentState();
}

class _SongsFragmentState extends State<SongsFragment> {

  var scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController.addListener(() {
      appState.setMainViewState(() {
        appState.fragmentTitleMinimized = scrollController.offset > 60 && appState.selectedSongs == null;
      });
    });
    appState.requestScrollToTop = () {
      scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Song> songList = [];
    List<Widget> children = [];
    appStorage.songs.forEach((key, song) {
      songList.add(song);
    });
    children.add(Container(
      height: 50,
    ));
    for (int i = 0; i < songList.length; i++) {
      var music = songList[i];
      children.add(SongListItem(song: music, index: i));
    }
    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
