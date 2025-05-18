
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/item/song_list_item.dart';

import '../components/image/album_cover.dart';


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
    appState.setFragmentState = setState;
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
      var albumCover = Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AlbumCover(
                album: song.album,
              ),
            )
        ),
      );
      children.add(SongListItem(song: song, playlistId: "", albumCover: albumCover));
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
