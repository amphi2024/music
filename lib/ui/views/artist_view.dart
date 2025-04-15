import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/item/album_grid_item.dart';
import 'package:music/ui/components/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';

import '../../models/app_storage.dart';

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
          SliverGrid.builder(
              itemCount: albumList.length,
              itemBuilder: (context, index) => AlbumGridItem(album: albumList[index]),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                childAspectRatio: 0.6))
        ]
      ),
    );
  }
}
