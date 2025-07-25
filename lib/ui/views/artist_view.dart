import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/item/album_grid_item.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';

import '../../models/app_storage.dart';
import '../../models/player_service.dart';
import '../fragments/components/floating_button.dart';
import 'album_view.dart';

class ArtistView extends StatelessWidget {

  final Artist artist;
  const ArtistView({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    List<Album> albumList = [];
    for(var id in artist.albums) {
      var album = appStorage.albums[id];
      if(album != null) {
        albumList.add(album);
      }
    }

    var imageSize = MediaQuery.of(context).size.width - 100;
    final String playlistId = "!ARTIST,${artist.id}";
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width + 80,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: GestureDetector(
                onLongPress: () {
                  showDialog(context: context, builder: (context) => EditArtistDialog(artist: artist, onSave: (result) {
                    appState.setMainViewState(() {

                    });
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    artist.name.byContext(context),
                    style: TextStyle(
                        fontSize: 15
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              background: Center(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ArtistProfileImage(artist: artist)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(right: 15), child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
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
                  })),
                  FloatingButton(icon: Icons.shuffle, onPressed: () {
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
                  })
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
            sliver: SliverGrid.builder(
                itemCount: albumList.length,
                itemBuilder: (context, index) => AlbumGridItem(showArtistName: false, album: albumList[index], onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AlbumView(album: albumList[index]),
                      ));
                }),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                  childAspectRatio: 0.65)),
          )
        ]
      ),
    );
  }
}
