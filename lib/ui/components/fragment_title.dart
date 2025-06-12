import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/models/sort_option.dart';
import 'package:music/ui/components/add_item_button.dart';

import '../dialogs/settings_dialog.dart';
import 'account/account_button.dart';

class FragmentTitle extends StatelessWidget {
  final String title;

  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var textTheme = themeData.textTheme;
    double scaleValue = (textTheme.bodyMedium?.fontSize ?? 15) / (textTheme.headlineMedium?.fontSize ?? 20);

    var padding = EdgeInsets.only(left: 15.0, right: 5);
    double height = 55;
    if(Platform.isAndroid && App.isWideScreen(context)) {
      padding = EdgeInsets.only(left: 15.0, right: 5, top: MediaQuery.of(context).padding.top);
      height += MediaQuery.of(context).padding.top;
    }


    return Container(
      height: height,
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor.withAlpha(125)),
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: appState.fragmentTitleShowing ? 1 : 0,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 750),
              child: AnimatedAlign(
                alignment: appState.fragmentTitleMinimized ? Alignment.center : Alignment.centerLeft,
                curve: Curves.easeOutQuint,
                duration: const Duration(milliseconds: 750),
                child: appState.selectedSongs == null
                    ? AnimatedScale(
                        scale: appState.fragmentTitleMinimized ? scaleValue : 1,
                        curve: Curves.easeOutQuint,
                        duration: const Duration(milliseconds: 750),
                        child: Text(title, style: Theme.of(context).textTheme.headlineMedium))
                    : IconButton(
                        onPressed: () {
                          appState.setState(() {
                            appState.selectedSongs = null;
                          });
                        },
                        icon: Icon(Icons.check)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(visible: App.isDesktop() || App.isWideScreen(context), child: AccountButton()),
                  Visibility(visible: App.isDesktop() || App.isWideScreen(context), child: AddItemButton()),
                  Visibility(
                    visible: App.isDesktop() || App.isWideScreen(context),
                    child: IconButton(
                        onPressed: () {
                          showDialog(context: context, builder: (context) => SettingsDialog());
                        },
                        icon: Icon(Icons.settings)),
                  ),
                  PopupMenuButton(
                      itemBuilder: (context) {
                        var playlistId = appState.showingPlaylistId ?? "";
                        final fragmentIndex = appState.fragmentIndex;
                        switch (fragmentIndex) {
                          case FragmentIndex.songs:
                            playlistId = "!SONGS";
                            break;
                          case FragmentIndex.archive:
                            playlistId = "!ARCHIVE";
                            break;
                          case FragmentIndex.artists:
                            playlistId = "!ARTISTS";
                            break;
                          case FragmentIndex.albums:
                            playlistId = "!ALBUMS";
                            break;
                        }
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
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.titleDescending);
                                }
                                else {
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.title);
                                }
                              })
                        ];

                        if (fragmentIndex != FragmentIndex.artists) {
                          items.add(PopupMenuItem(
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
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.artistDescending);
                                }
                                else {
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.artist);
                                }
                              }));
                        }

                        if (fragmentIndex != FragmentIndex.albums && fragmentIndex != FragmentIndex.artists) {
                          items.add(PopupMenuItem(
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
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.albumDescending);
                                }
                                else {
                                  sortListByOption(playlistId: playlistId, fragmentIndex: fragmentIndex, sortOption: SortOption.album);
                                }
                              }));
                        }

                        if (appState.selectedSongs != null) {
                          items.add(PopupMenuItem(child: Text(AppLocalizations.of(context).get("@add_to_playlist")), onTap: () {}));
                          items.add(PopupMenuItem(child: Text(AppLocalizations.of(context).get("@move_to_archive")), onTap: () {}));
                        }
                        return items;
                      },
                      icon: Icon(Icons.more_horiz_outlined)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void sortListByOption({required String playlistId, required int fragmentIndex, required String sortOption}) {
  switch (fragmentIndex) {
    case FragmentIndex.songs:
      appState.setFragmentState(() {
        appStorage.songIdList.sortSongList(sortOption);
      });
      appCacheData.setSortOption(sortOption: sortOption, playlistId: "!SONGS");
      break;
    case FragmentIndex.archive:
      appState.setFragmentState(() {
        appStorage.archiveIdList.sortSongList(sortOption);
      });
      appCacheData.setSortOption(sortOption: sortOption, playlistId: "!ARCHIVE");
      break;
    case FragmentIndex.artists:
      appState.setFragmentState(() {
        appStorage.artistIdList.sortArtistList(sortOption);
      });
      appCacheData.setSortOption(sortOption: sortOption, playlistId: "!ARTISTS");
      break;
    case FragmentIndex.albums:
      appState.setFragmentState(() {
        appStorage.albumIdList.sortAlbumList(sortOption);
      });
      appCacheData.setSortOption(sortOption: sortOption, playlistId: "!ALBUMS");
      break;
    default:
      appState.setFragmentState(() {
        appStorage.playlists.get(playlistId).songs.sortSongList(sortOption);
      });
      appCacheData.setSortOption(sortOption: sortOption, playlistId: playlistId);
      break;
  }
  appCacheData.save();
}
