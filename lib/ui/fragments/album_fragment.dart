import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/fragments/components/album_fragment_title.dart';

class AlbumFragment extends StatefulWidget {
  const AlbumFragment({super.key});

  @override
  State<AlbumFragment> createState() => _AlbumFragmentState();
}

class _AlbumFragmentState extends State<AlbumFragment> {

  var scrollController = ScrollController();

  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    scrollController.dispose();
    overlayEntry.remove();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned(
              left: 205,
                top: 5,
                child: IconButton(onPressed: () {
                  appState.setMainViewState(() {
                    appState.fragmentIndex = FragmentIndex.albums;
                    appState.showingAlbumId = null;
                    appState.fragmentTitleShowing = true;
                  });
                }, icon: Icon(Icons.arrow_back_ios_new, size: 15,))),
          ],
        ),
      );
      overlay.insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final album = appStorage.albums.get(appState.showingAlbumId ?? "");
    children.add(
      Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 50),
        child: AlbumFragmentTitle(album: album),
      )
    );
    for(var songId in album.songs) {
      var trackNumberWidget = Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Text(appStorage.songs.get(songId).trackNumber.toString()),
      );
      children.add(SongListItem(song: appStorage.songs.get(songId), playlistId: "!ALBUM,${album.id}", albumCover: trackNumberWidget));
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
