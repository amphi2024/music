import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/dialogs/edit_album_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';
import '../../providers/artists_provider.dart';
import '../../services/player_service.dart';

class AlbumPage extends ConsumerWidget {
  final Album album;

  const AlbumPage({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumPlaylist = ref
        .watch(playlistsProvider)
        .playlists
        .get("!ALBUM,${album.id}");
    final songs = ref.watch(songsProvider);
    final songIdList = ref.watch(playlistsProvider).playlists.get("!ALBUM,${album.id}").songs;

    final imageSize = MediaQuery
        .of(context)
        .size
        .width - 100;
    final artist = ref.watch(artistsProvider).get(album.id);
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
                  showDialog(context: context, builder: (context) => EditAlbumDialog(album: Album.fromMap(album.toSqlInsertMap()), ref: ref));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    album.title.byContext(context),
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
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
                      child: AlbumCover(
                        album: album,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Text(
                    artist.name.byContext(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.only(right: 15), child: FloatingButton(icon: Icons.play_arrow, onPressed: () {
                          if(songIdList.isNotEmpty) {
                            final song = ref.read(songsProvider).get(songIdList[0]);
                            playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}", ref: ref, shuffle: false);
                          }
                        })),
                        FloatingButton(icon: Icons.shuffle, onPressed: () {
                          if(songIdList.isNotEmpty) {
                            final index = Random().nextInt(songIdList.length);
                            final song = ref.read(songsProvider).get(songIdList[index]);
                            playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}", ref: ref, shuffle: true);
                          }
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: 80 + MediaQuery
                .of(context)
                .padding
                .bottom),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return SongListItem(song: songs.get(albumPlaylist.songs[index]), playlistId: "!ALBUM,${album.id}", coverStyle: CoverStyle.trackNumber);
                },
                childCount: albumPlaylist.songs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
