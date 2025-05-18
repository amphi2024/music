import 'package:flutter/material.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../../models/fragment_index.dart';
import '../components/item/song_list_item.dart';
import 'components/album_fragment_title.dart';

class ArtistFragment extends StatefulWidget {
  const ArtistFragment({super.key});

  @override
  State<ArtistFragment> createState() => _ArtistFragmentState();
}

class _ArtistFragmentState extends State<ArtistFragment> {
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
    final artist = appStorage.artists.get(appState.showingArtistId ?? "");
    for(var albumId in artist.albums) {
      final album = appStorage.albums.get(albumId);
      children.add(
          AlbumFragmentTitle(album: album)
      );
      for(var songId in album.songs) {
        var trackNumberWidget = Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(appStorage.songs.get(songId).trackNumber.toString()),
        );
        children.add(SongListItem(song: appStorage.songs.get(songId), playlistId: "", albumCover: trackNumberWidget));
      }
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
