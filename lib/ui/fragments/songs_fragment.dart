
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/item/song_list_item.dart';

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
    List<Widget> children = [];
    children.add(Container(
      height: 50,
    ));
    for (int i = 0; i < appStorage.songIdList.length; i++) {
      final id = appStorage.songIdList[i];
      var song = appStorage.songs.get(id);
      children.add(SongListItem(song: song));
    }
    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
