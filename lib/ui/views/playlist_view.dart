import 'dart:math';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/playlist_thumbnail.dart';

import '../../models/app_cache.dart';
import '../../models/app_state.dart';
import '../../models/player_service.dart';
import '../../models/sort_option.dart';
import '../components/image/album_cover.dart';
import '../fragments/components/floating_button.dart';

class PlaylistView extends StatefulWidget {

  final Playlist playlist;
  const PlaylistView({super.key, required this.playlist});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {

  void sortListByOption(String sortOption) {
       setState(() {
          appStorage.playlists.get(widget.playlist.id).songs.sortSongList(sortOption);
        });
        appCacheData.setSortOption(sortOption: sortOption, playlistId: widget.playlist.id);
    appCacheData.save();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    var imageSize = MediaQuery.of(context).size.width - 100;

    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width + 80,
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
                              if(sortOption == SortOption.title) {
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
                              if(sortOption == SortOption.artist) {
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
                              if(sortOption == SortOption.album) {
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
                      if(playlist.songs.isNotEmpty) {
                        appState.setState(() {
                          var id = playlist.songs[0];
                          var song = appStorage.songs.get(id);
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: playlist.id);
                          playerService.shuffled = false;
                        });
                      }
                    })),
                    FloatingButton(icon: Icons.shuffle, onPressed: () {
                      if(playlist.songs.isNotEmpty) {
                        var index = Random().nextInt(playlist.songs.length);
                        var id = playlist.songs[index];
                        var song = appStorage.songs.get(id);
                        appState.setState(() {
                          playerService.isPlaying = true;
                          playerService.startPlay(song: song, playlistId: playlist.id, shuffle: true);
                        });
                      }
                    })
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var id = playlist.songs[index];
                    var song = appStorage.songs.get(id);
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
                    return SongListItem(song: song, playlistId: playlist.id, albumCover: albumCover);
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
