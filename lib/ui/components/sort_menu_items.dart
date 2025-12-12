import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_cache.dart';
import '../../models/sort_option.dart';
import '../../providers/playlists_provider.dart';

List<PopupMenuItem> sortMenuItems(
    {required BuildContext context, required WidgetRef ref, required String showingPlaylistId}) {
  switch (showingPlaylistId) {
    case "!ALBUMS":
      return [
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.title,
            sortOptionDescending: SortOption.titleDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_title")),
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.artist,
            sortOptionDescending: SortOption.artistDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_artist"))
      ];
    case "!ARTISTS":
      return [
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.title,
            sortOptionDescending: SortOption.titleDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_title"))
      ];
    default:
      return [
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.title,
            sortOptionDescending: SortOption.titleDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_title")),
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.artist,
            sortOptionDescending: SortOption.artistDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_artist")),
        sortMenuSortButton(
            context: context,
            sortOption: SortOption.album,
            sortOptionDescending: SortOption.albumDescending,
            ref: ref,
            showingPlaylistId: showingPlaylistId,
            title: AppLocalizations.of(context).get("@sort_by_album"))
      ];
  }
}

PopupMenuItem sortMenuSortButton(
    {required BuildContext context,
    required String sortOption,
    required String sortOptionDescending,
    required WidgetRef ref,
    required String showingPlaylistId,
    required String title}) {
  final currentSortOption = appCacheData.sortOption(showingPlaylistId);
  return PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Visibility(
              visible: currentSortOption == sortOption || currentSortOption == sortOptionDescending,
              child: Icon(currentSortOption == sortOption ? Icons.arrow_upward : Icons.arrow_downward, color: Theme.of(context).highlightColor))
        ],
      ),
      onTap: () {
        if (currentSortOption == sortOption) {
          sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: sortOptionDescending);
        } else {
          sortListByOption(playlistId: showingPlaylistId, ref: ref, sortOption: sortOption);
        }
      });
}

void sortListByOption({required String playlistId, required WidgetRef ref, required String sortOption}) {
  appCacheData.setSortOption(sortOption: sortOption, playlistId: playlistId);
  appCacheData.save();
  ref.read(playlistsProvider.notifier).sortItems(playlistId, sortOption);
}
