
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/fragments/components/fragment_padding.dart';

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
    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: appStorage.songIdList.length,
      itemBuilder: (context, index) {
          final id = appStorage.songIdList[index];
          var song = appStorage.songs.get(id);
          var albumCover = Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AlbumCover(album: song.album),
              ),
            ),
          );
          return SongListItem(song: song, playlistId: "", albumCover: albumCover);

      },
    );
  }
}
