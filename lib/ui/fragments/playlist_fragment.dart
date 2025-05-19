import 'package:flutter/material.dart';
import 'package:music/ui/fragments/components/playlist_fragment_title.dart';
import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';

class PlaylistFragment extends StatefulWidget {
  const PlaylistFragment({super.key});

  @override
  State<PlaylistFragment> createState() => _PlaylistFragmentState();
}

class _PlaylistFragmentState extends State<PlaylistFragment> {

  final scrollController = ScrollController();

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
          appState.fragmentTitleShowing = true;
          appState.fragmentTitleMinimized = true;
        });
      }
      else {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = false;
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
    final playlist = appStorage.playlists.get(appState.showingPlaylistId ?? "");
    children.add(
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 5, top: 50),
          child: PlaylistFragmentTitle(playlist: playlist)
        )
    );
    for(var songId in playlist.songs) {
      var song = appStorage.songs.get(songId);
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
            )),
      );
      children.add(SongListItem(song: appStorage.songs.get(songId), playlistId: playlist.id, albumCover: albumCover));
    }
    children.add(
        SizedBox(height: 80,)
    );

    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
