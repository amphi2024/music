import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';

import '../providers/songs_provider.dart';

Future<void> moveSelectedSongsToTrash({required List<String> selectedItems, required String showingPlaylistId, required WidgetRef ref}) async {
  final songs = ref.read(songsProvider);
  for(var id in selectedItems) {
    final song = songs.get(id);
    song.deleted = DateTime.now();
    song.save();
    ref.read(songsProvider.notifier).insertSong(song);
    ref.read(playlistsProvider.notifier).notifySongUpdate(song);
  }
}