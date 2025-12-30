import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/utils/screen_size.dart';

import '../../../providers/playlists_provider.dart';
import '../../../providers/providers.dart';
import '../../../providers/songs_provider.dart';
import '../../../utils/move_to_trash.dart';
import '../../components/select_playlist_bottom_sheet.dart';

List<Widget> mainPageSelectionActions({required WidgetRef ref, required BuildContext context, required List<String> selectedSongs, required String showingPlaylistId}) {
  final trashButton = IconButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return ConfirmationDialog(
                  title: AppLocalizations.of(context).get("dialog_title_move_to_trash"),
                  onConfirmed: () {
                    moveSelectedSongsToTrash(selectedItems: selectedSongs, showingPlaylistId: showingPlaylistId, ref: ref);
                    ref.read(selectedItemsProvider.notifier).endSelection();
                  });
            });
      },
      icon: Icon(Icons.delete));
  if(isDesktop()) {
    return [
      trashButton
    ];
  }
  return [
    IconButton(
        onPressed: () {
          ref.read(playingBarShowingProvider.notifier).set(false);
          showModalBottomSheet(context: context, builder: (context) => SelectPlaylistBottomSheet(songIdList: selectedSongs))
              .then((value) {
            ref.read(playingBarShowingProvider.notifier).set(true);
            ref.read(selectedItemsProvider.notifier).endSelection();
          });
        },
        icon: Icon(Icons.playlist_add)),
    IconButton(onPressed: () {
      final songs = ref.watch(songsProvider);
      for(var id in selectedSongs) {
        final song = songs.get(id);
        song.archived = true;
        song.save();
        ref.read(songsProvider.notifier).insertSong(song);
        ref.read(playlistsProvider.notifier).notifySongUpdate(song);
      }
      ref.read(selectedItemsProvider.notifier).endSelection();
    }, icon: Icon(Icons.archive)),
    trashButton
  ];
}

IconButton mainPageArchiveButton({required WidgetRef ref, required List<String> selectedSongs}) {
  return IconButton(onPressed: () {
    final songs = ref.watch(songsProvider);
    for(var id in selectedSongs) {
      final song = songs.get(id);
      song.archived = true;
      song.save();
      ref.read(songsProvider.notifier).insertSong(song);
      ref.read(playlistsProvider.notifier).notifySongUpdate(song);
    }
    ref.read(selectedItemsProvider.notifier).endSelection();
  }, icon: Icon(Icons.archive));
}