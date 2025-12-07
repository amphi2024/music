import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';

import '../../models/app_cache.dart';
import '../../models/sort_option.dart';
import '../fragments/components/floating_button.dart';

class PlaylistView extends ConsumerStatefulWidget {

  final Playlist playlist;

  const PlaylistView({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends ConsumerState<PlaylistView> {

  void sortListByOption(String sortOption) {
    //    setState(() {
    //       appStorage.playlists.get(widget.playlist.id).songs.sortSongList(sortOption);
    //     });
    //     appCacheData.setSortOption(sortOption: sortOption, playlistId: widget.playlist.id);
    // appCacheData.save();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    var imageSize = MediaQuery
        .of(context)
        .size
        .width - 100;

    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery
                  .of(context)
                  .size
                  .width + 80,
              pinned: true,
              actions: [
                PopupMenuButton(
                    itemBuilder: (context) {
                      var playlistId = playlist.id;
                      final sortOption = appCacheData.sortOption(playlistId);
                      final items = [
                        PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context).get("@sort_by_title")),
                                Visibility(
                                    visible: sortOption == SortOption.title || sortOption == SortOption.titleDescending,
                                    child: Icon(sortOption == SortOption.title ? Icons.arrow_upward : Icons.arrow_downward))
                              ],
                            ),
                            onTap: () {
                              if (sortOption == SortOption.title) {
                                sortListByOption(SortOption.titleDescending);
                              }
                              else {
                                sortListByOption(SortOption.title);
                              }
                            }),
                        PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context).get("@sort_by_artist")),
                                Visibility(
                                    visible: sortOption == SortOption.artist || sortOption == SortOption.artistDescending,
                                    child: Icon(sortOption == SortOption.artist ? Icons.arrow_upward : Icons.arrow_downward))
                              ],
                            ),
                            onTap: () {
                              if (sortOption == SortOption.artist) {
                                sortListByOption(SortOption.artistDescending);
                              }
                              else {
                                sortListByOption(SortOption.artist);
                              }
                            }),
                        PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context).get("@sort_by_album")),
                                Visibility(
                                    visible: sortOption == SortOption.album || sortOption == SortOption.albumDescending,
                                    child: Icon(sortOption == SortOption.album ? Icons.arrow_upward : Icons.arrow_downward))
                              ],
                            ),
                            onTap: () {
                              if (sortOption == SortOption.album) {
                                sortListByOption(SortOption.albumDescending);
                              }
                              else {
                                sortListByOption(SortOption.album);
                              }
                            })
                      ];
                      return items;
                    },
                    icon: Icon(Icons.more_horiz_outlined))
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
                  onLongPress: () {

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      playlist.title,
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
                        child: PlaylistThumbnail(playlist: playlist)),
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
                      if (playlist.songs.isNotEmpty) {
                        // appState.setState(() {
                        //   var id = playlist.songs[0];
                        //   var song = ref.watch(songsProvider).get(id);
                        //   playerService.isPlaying = true;
                        //   playerService.startPlay(song: song, playlistId: playlist.id);
                        //   playerService.shuffled = false;
                        // });
                      }
                    })),
                    FloatingButton(icon: Icons.shuffle, onPressed: () {
                      // if (playlist.songs.isNotEmpty) {
                      //   var index = Random().nextInt(playlist.songs.length);
                      //   var id = playlist.songs[index];
                      //   var song = ref.watch(songsProvider).get(id);
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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final id = playlist.songs[index];
                  final song = ref.watch(songsProvider).get(id);
                  return SongListItem(song: song, playlistId: playlist.id);
                },
                    childCount: playlist.songs.length
                ),
              ),
            )
          ]
      ),
    );
  }
}
