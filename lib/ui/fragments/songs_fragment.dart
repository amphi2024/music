
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/item/song_list_item.dart';


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
      if(scrollController.offset > 60 && appState.selectedSongs == null) {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = true;
        });
      }
      else {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
        });
      }
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
    children.add(Container(
      height: 80,
    ));
    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
