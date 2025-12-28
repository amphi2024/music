import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:amphi/widgets/move_window_button_or_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/utils/move_to_trash.dart';

import '../../../providers/providers.dart';
import '../../components/add_item_button.dart';
import '../../components/sort_menu_items.dart';

class WideMainPageFragmentTitle extends ConsumerWidget {
  const WideMainPageFragmentTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showingPlaylistId = ref.watch(showingPlaylistIdProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    final padding = MediaQuery.of(context).padding;
    final selectedSongs = ref.watch(selectedItemsProvider);

    return SizedBox(
      height: 55 + padding.top,
      child: Row(
        children: [
          if (showingPlaylistId.contains(",")) ...[
            IconButton(
                onPressed: () {
                  ref.read(showingPlaylistIdProvider.notifier).set("${showingPlaylistId.split(",").first}S");
                },
                icon: Icon(Icons.arrow_back_ios_new))
          ],
          PopupMenuButton(
              itemBuilder: (context) {
                return sortMenuItems(context: context, ref: ref, showingPlaylistId: showingPlaylistId);
              },
              icon: Icon(Icons.view_agenda)),
          const Expanded(child: MoveWindowOrSpacer()),
          () {
            if(searchKeyword != null) {
              return SizedBox(
                  width: 250,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      onSubmitted: (text) {
                        if(text.isEmpty) {
                          ref.read(searchKeywordProvider.notifier).endSearch();
                          return;
                        }
                        ref.read(searchKeywordProvider.notifier).setKeyword(text);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 14),
                        contentPadding: EdgeInsets.only(right: 5, top: 5, bottom: 5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
                              style: BorderStyle.solid,
                              width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
                              style: BorderStyle.solid,
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              style: BorderStyle.solid,
                              width: 2),
                        ),
                      ),
                    ),
                  ));
            }
            return
              IconButton(onPressed: () {
                ref.read(searchKeywordProvider.notifier).startSearch();
              }, icon: Icon(Icons.search));
          } (),
          AddItemButton(),
          if(selectedSongs != null && showingPlaylistId == "!SONGS") ... [
            IconButton(onPressed: () {
              showDialog(context: context, builder: (context) {
                return ConfirmationDialog(title: AppLocalizations.of(context).get("move_to_trash"), onConfirmed: () {
                  moveSelectedSongsToTrash(selectedItems: selectedSongs, showingPlaylistId: showingPlaylistId, ref: ref);
                });
              });
            }, icon: Icon(Icons.delete))
          ],
          if(selectedSongs != null && !showingPlaylistId.startsWith("!")) ... [
            IconButton(onPressed: () {
              final playlist = ref.read(playlistsProvider).playlists.get(showingPlaylistId);
              for(var id in selectedSongs) {
                playlist.songs.remove(id);
              }
              playlist.initThumbnailIndexes();
              playlist.save();
              ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
            }, icon: Icon(Icons.remove))
          ]
        ],
      ),
    );
  }
}