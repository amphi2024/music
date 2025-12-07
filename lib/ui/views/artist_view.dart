import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/components/item/album_grid_item.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';
import 'package:music/utils/localized_title.dart';

import '../fragments/components/floating_button.dart';
import 'album_view.dart';

class ArtistView extends ConsumerWidget {

  final Artist artist;

  const ArtistView({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imageSize = MediaQuery
        .of(context)
        .size
        .width - 100;
    final albumIds = ref.watch(playlistsProvider).playlists.get("!ARTIST,${artist.id}").songs;
    final albums = ref.watch(albumsProvider);
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery
                  .of(context)
                  .size
                  .width + 80,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
                  onLongPress: () {
                    showDialog(context: context, builder: (context) => EditArtistDialog(artist: artist, ref: ref));
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
                      // var albumId = artist.albums.firstOrNull;
                      // if(albumId != null) {
                      //   var songId = appStorage.albums.get(albumId).songs.firstOrNull;
                      //   if(songId != null) {
                      //     // appState.setState(() {
                      //     //   playerService.isPlaying = true;
                      //     //   playerService.shuffled = false;
                      //     //   playerService.startPlay(song: ref.watch(songsProvider).get(songId), playlistId: playlistId);
                      //     // });
                      //   }
                      // }
                    })),
                    FloatingButton(icon: Icons.shuffle, onPressed: () {
                      // var albumId = artist.albums.firstOrNull;
                      // if(albumId != null) {
                      //   var songId = appStorage.albums.get(albumId).songs.firstOrNull;
                      //   if(songId != null) {
                      //     // appState.setState(() {
                      //     //   playerService.isPlaying = true;
                      //     //   playerService.startPlay(song: ref.watch(songsProvider).get(songId), playlistId: playlistId, shuffle: true);
                      //     // });
                      //   }
                      // }
                    })
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 80 + MediaQuery
                  .of(context)
                  .padding
                  .bottom),
              sliver: SliverGrid.builder(
                  itemCount: albumIds.length,
                  itemBuilder: (context, index) {
                    final album = albums.get(albumIds[index]);
                    return AlbumGridItem(showArtistName: false, album: album, onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AlbumView(album: album),
                            ));
                      });
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                      childAspectRatio: 0.65)),
            )
          ]
      ),
    );
  }
}
