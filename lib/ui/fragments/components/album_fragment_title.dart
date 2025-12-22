import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/album.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';

import '../../../providers/artists_provider.dart';
import '../../dialogs/edit_album_dialog.dart';

class AlbumFragmentTitle extends ConsumerWidget {
  final Album album;

  const AlbumFragmentTitle({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider).getAll(album.artistIds);

    return Row(
      children: [
        SizedBox(
            width: 250,
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AlbumCover(album: album),
            ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title.byContext(context),
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  maxLines: 3,
                ),
                Text(
                  artists.localizedName(),
                  maxLines: 3,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FloatingButton(
                              icon: Icons.play_arrow,
                              onPressed: () {
                                // if (album.songs.isNotEmpty) {
                                // appState.setState(() {
                                //   var id = album.songs[0];
                                //   var song = ref.watch(songsProvider).get(id);
                                //   playerService.isPlaying = true;
                                //   playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}");
                                //   playerService.shuffled = false;
                                // });
                                // }
                              }),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: FloatingButton(
                                icon: Icons.shuffle,
                                onPressed: () {
                                  // if (album.songs.isNotEmpty) {
                                  //   int index = Random().nextInt(album.songs.length);
                                  //   var id = album.songs[index];
                                  //   var song = ref.watch(songsProvider).get(id);
                                  //   // appState.setState(() {
                                  //   //   playerService.isPlaying = true;
                                  //   //   playerService.startPlay(song: song, playlistId: "!ALBUM,${album.id}", shuffle: true);
                                  //   // });
                                  // }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton(
                        itemBuilder: (context) {
                      return [
                        //TODO: localize
                        PopupMenuItem(child: Text("edit"), onTap: () {
                          showDialog(context: context, builder: (context) => EditAlbumDialog(album: Album.fromMap(album.toSqlInsertMap()), ref: ref));
                        }),
                        PopupMenuItem(child: Text("move to trash"), onTap: () {
                          showDialog(context: context, builder: (context) => ConfirmationDialog(title: "are you want to?", onConfirmed: () {
                            album.deleted = DateTime.now();
                            album.save();
                            ref.read(albumsProvider.notifier).insertAlbum(album);
                            ref.read(playlistsProvider.notifier).notifyAlbumUpdate(album);
                          }));
                        })
                      ];
                    })
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
