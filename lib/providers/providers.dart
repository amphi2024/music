import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_cache.dart';
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

  bool ctrlPressed = false;
  bool shiftPressed = false;

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

  void addAll(List<String> items) {
    final list = [...state!];
    list.addAll(items);
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

class WidthNotifier extends Notifier<double> {
  @override
  double build() {
    return 0;
  }

  double get minimumWidth => 0;

  void set(double value) {
    if(minimumWidth > value) {
      return;
    }
    state = value;
  }
}

class SideBarWidthNotifier extends WidthNotifier {
  @override
  double build() {
    return appCacheData.sidebarWidth;
  }

  @override
  double get minimumWidth => 200;
}

final sideBarWidthProvider = NotifierProvider<SideBarWidthNotifier, double>(SideBarWidthNotifier.new);

class NowPlayingPanelWidthNotifier extends WidthNotifier {
  @override
  double build() {
    return appCacheData.nowPlayingPanelWidth;
  }

  @override
  double get minimumWidth => 300;
}

final nowPlayingPanelWidthProvider = NotifierProvider<NowPlayingPanelWidthNotifier, double>(NowPlayingPanelWidthNotifier.new);

final searchKeywordProvider = NotifierProvider<SearchKeywordNotifier, String?>(SearchKeywordNotifier.new);

class SearchKeywordNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setKeyword(String keyword) {
    state = keyword;
  }

  void startSearch() {
    state = "";
  }

  void endSearch() {
    state = null;
  }
}