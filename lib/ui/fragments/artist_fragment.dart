import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../../models/fragment_index.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

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
                    appState.fragmentIndex = FragmentIndex.artists;
                    appState.showingArtistId = null;
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
    final artist = appStorage.artists.get(appState.showingArtistId ?? "");
    final String playlistId = "!ARTIST,${artist.id}";

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: artist.albums.length + 3,
      itemBuilder: (context, index) {
        if(index == 0) {
          return  Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: ArtistProfileImage(artist: artist),
                  ),
                ),
              ],
            ),
          );
        }
        else if(index == 1) {
          return GestureDetector(
            onLongPress: () {
              showDialog(context: context, builder: (context) => EditArtistDialog(artist: artist, onSave: (artist) {
                appState.setFragmentState(() {

                });
              }));
            },
            child: Text(artist.name.byContext(context), textAlign: TextAlign.center, style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),),
          );
        }
        else if(index == 2) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingButton(icon: Icons.play_arrow, onPressed: () {
                var albumId = artist.albums.firstOrNull;
                if(albumId != null) {
                  var songId = appStorage.albums.get(albumId).songs.firstOrNull;
                  if(songId != null) {
                    appState.setState(() {
                      playerService.isPlaying = true;
                      playerService.shuffled = false;
                      playerService.startPlay(song: appStorage.songs.get(songId), playlistId: playlistId);
                    });
                  }
                }
              }),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                  var albumId = artist.albums.firstOrNull;
                  if(albumId != null) {
                    var songId = appStorage.albums.get(albumId).songs.firstOrNull;
                    if(songId != null) {
                      appState.setState(() {
                        playerService.isPlaying = true;
                        playerService.startPlay(song: appStorage.songs.get(songId), playlistId: playlistId, shuffle: true);
                      });
                    }
                  }
                }),
              ),
            ],
          );
        }
        else {
          final albumId = artist.albums[index - 3];
          final album = appStorage.albums.get(albumId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 30),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AlbumCover(album: album),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          album.title.byContext(context),
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...album.songs.map((songId) {
                final song = appStorage.songs.get(songId);
                final trackNumberWidget = Padding(
                  padding: const EdgeInsets.only(left: 30, right: 20),
                  child: Text(song.trackNumber.toString()),
                );
                return SongListItem(
                  song: song,
                  playlistId: playlistId,
                  albumCover: trackNumberWidget,
                );
              }).toList(),
            ],
          );
        }
      },
    );
  }
}
