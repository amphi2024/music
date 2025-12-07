import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/playlists_provider.dart';

class PlayingBarShowingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  void set(bool value) {
    state = value;
  }
}

final playingBarShowingProvider = NotifierProvider<PlayingBarShowingNotifier, bool>(PlayingBarShowingNotifier.new);

class PlayingBarExpandedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }
}

final playingBarExpandedProvider = NotifierProvider(PlayingBarExpandedNotifier.new);

class SelectedItemsNotifier extends Notifier<List<String>?> {
  @override
  List<String>? build() {
    return null;
  }

  void startSelection() {
    state = [];
  }

  void endSelection() {
    state = null;
  }

  void addItem(String id) {
    state = [...state!, id];
  }

  void removeItem(String id) {
    final list = [...state!];
    list.remove(id);
    state = list;
  }
}

final selectedItemsProvider = NotifierProvider<SelectedItemsNotifier, List<String>?>(SelectedItemsNotifier.new);

class ShowingPlaylistIdNotifier extends Notifier<String> {
  @override
  String build() {
    return "!SONGS";
  }

  void set(String value) {
    state = value;
  }
}

final showingPlaylistIdProvider = NotifierProvider<ShowingPlaylistIdNotifier, String>(ShowingPlaylistIdNotifier.new);

Playlist showingPlaylist(WidgetRef ref) {
  return ref.watch(playlistsProvider).playlists.get(ref.watch(showingPlaylistIdProvider));
}

class FloatingMenuShowingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }
}

final floatingMenuShowingProvider = NotifierProvider<FloatingMenuShowingNotifier, bool>(FloatingMenuShowingNotifier.new);