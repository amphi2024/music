import 'package:flutter/material.dart';
import 'package:music/ui/fragments/components/playlist_fragment_title.dart';
import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

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
    final playlist = appStorage.playlists.get(appState.showingPlaylistId ?? "");

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: playlist.songs.length + 1,
      itemBuilder: (context, index) {
        if(index == 0) {
          return Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 5, top: 10),
              child: PlaylistFragmentTitle(playlist: playlist)
          );
        }
        else {
          var songId = playlist.songs[index - 1];
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
          return SongListItem(song: appStorage.songs.get(songId), playlistId: playlist.id, albumCover: albumCover);
        }
      },
    );
  }
}
