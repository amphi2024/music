import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/fragments/components/floating_button.dart';

import '../../models/app_storage.dart';
import '../../models/fragment_index.dart';
import '../../models/music/song.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class GenreFragment extends StatefulWidget {
  const GenreFragment({super.key});

  @override
  State<GenreFragment> createState() => _GenreFragmentState();
}

class _GenreFragmentState extends State<GenreFragment> {
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
                    appState.fragmentIndex = FragmentIndex.genres;
                    appState.showingGenre = null;
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
    List<Song> songList = [];
    final genre = appStorage.genres[appState.showingGenre ?? ""] ?? {};
    final genreName = genre["default"];
    final playlistId = "!GENRE,${genreName}";
    appStorage.songs.forEach((key, song) {
      for (var genre in song.genre) {
        if (genre is Map<String, dynamic> && genre.containsValue(genreName)) {
          songList.add(song);
        }
      }
    });

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: songList.length + 2,
      itemBuilder: (context, index) {
        if(index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 5),
            child: Text(genre.byContext(context), style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
            ),),
          );
        }
        else if(index == 1) {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 15),
                child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
                  appState.setState(() {
                    var song = songList.firstOrNull;
                    if(song != null) {
                      playerService.isPlaying = true;
                      playerService.shuffled = false;
                      playerService.startPlay(song: song, playlistId: playlistId);
                    }
                  });
                }),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 15),
                  child: FloatingButton(
                      icon: Icons.shuffle,
                      onPressed: () {
                        appState.setState(() {
                          var song = songList.firstOrNull;
                          if(song != null) {
                            playerService.isPlaying = true;
                            playerService.startPlay(song: song, playlistId: playlistId, shuffle: true);
                          }
                        });
                      }))
            ],
          );
        }
        else {
          var song = songList[index - 2];
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
          return SongListItem(song: song, playlistId: playlistId, albumCover: albumCover);
        }
      },
    );
  }
}
