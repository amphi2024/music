import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/sort_option.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/add_item_button.dart';

import '../dialogs/settings_dialog.dart';
import 'account/account_button.dart';

class FragmentTitle extends ConsumerWidget {
  final String title;

  const FragmentTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    double scaleValue = (textTheme.bodyMedium?.fontSize ?? 15) / (textTheme.headlineMedium?.fontSize ?? 20);
    final fragmentState = ref.watch(fragmentStateProvider);
    final fragmentTitleShowing = fragmentState.titleShowing;
    final fragmentTitleMinimized = fragmentState.titleMinimized;
    final selectedSongs = ref.watch(selectedItemsProvider);
    final showingPlaylistId = ref.watch(showingPlaylistIdProvider);

    var padding = EdgeInsets.only(left: 15.0, right: 5);
    double height = 55;
    if (Platform.isAndroid && App.isWideScreen(context)) {
      padding = EdgeInsets.only(left: 15.0, right: 5, top: MediaQuery
          .of(context)
          .padding
          .top);
      height += MediaQuery
          .of(context)
          .padding
          .top;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(color: themeData
          .cardColor
          .withAlpha(125)),
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            // AnimatedOpacity(
            //   opacity: fragmentTitleShowing ? 1 : 0,
            //   curve: Curves.easeOutQuint,
            //   duration: const Duration(milliseconds: 750),
            //   child: AnimatedAlign(
            //     alignment: fragmentTitleMinimized ? Alignment.center : Alignment.centerLeft,
            //     curve: Curves.easeOutQuint,
            //     duration: const Duration(milliseconds: 750),
            //     child: selectedSongs == null
            //         ? AnimatedScale(
            //         scale: fragmentTitleMinimized ? scaleValue : 1,
            //         curve: Curves.easeOutQuint,
            //         duration: const Duration(milliseconds: 750),
            //         child: Text(title, style: Theme
            //             .of(context)
            //             .textTheme
            //             .headlineMedium))
            //         : IconButton(
            //         onPressed: () {
            //           ref.read(selectedItemsProvider.notifier).endSelection();
            //         },
            //         icon: Icon(Icons.check)),
            //   ),
            // ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Visibility(visible: App.isDesktop() || App.isWideScreen(context), child: AccountButton()),
                  Visibility(visible: App.isDesktop() || App.isWideScreen(context), child: AddItemButton()),
                  // Visibility(
                  //   visible: App.isDesktop() || App.isWideScreen(context),
                  //   child: IconButton(
                  //       onPressed: () {
                  //         showDialog(context: context, builder: (context) => SettingsDialog());
                  //       },
                  //       icon: Icon(Icons.settings)),
                  // ),
                  PopupMenuButton(
                      itemBuilder: (context) {
                        final sortOption = appCacheData.sortOption(ref.watch(showingPlaylistIdProvider));
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
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.titleDescending);
                                }
                                else {
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.title);
                                }
                              })
                        ];

                        if (showingPlaylistId != "!ARTISTS") {
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
                                if (sortOption == SortOption.artist) {
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.artistDescending);
                                }
                                else {
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.artist);
                                }
                              }));
                        }

                        if (showingPlaylistId != "!ALBUMS" && showingPlaylistId != "!ARTISTS") {
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
                                if (sortOption == SortOption.album) {
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.albumDescending);
                                }
                                else {
                                  sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: SortOption.album);
                                }
                              }));
                        }

                        if (selectedSongs != null) {
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

void sortListByOption({required String playlistId, required WidgetRef ref, required String sortOption}) {
  ref.read(playlistsProvider.notifier).sortItems(playlistId, sortOption);
  appCacheData.setSortOption(sortOption: sortOption, playlistId: playlistId);
  appCacheData.save();
}
