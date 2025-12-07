import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';

import '../models/music/song.dart';

const repeatAll = 0;
const repeatOne = 1;
const playOnce = 2;

class PlayingSongsState {
  final String playlistId;
  final List<String> songs;
  final bool shuffled;
  final int playingSongIndex;

  const PlayingSongsState({required this.playlistId, required this.songs, required this.shuffled, required this.playingSongIndex});
}

class PlayingSongsNotifier extends Notifier<PlayingSongsState> {
  @override
  PlayingSongsState build() {
    return PlayingSongsState(playlistId: "!SONGS", songs: [""], shuffled: true, playingSongIndex: 0);
  }

  void setShuffled(bool value) {
    if (value) {
    } else {}
  }

  String playingSongId() {
    return state.songs[state.playingSongIndex];
  }

  Song playingSong() {
    final id = playingSongId();
    return ref.read(songsProvider).get(id);
  }

  void setPlayingSongIndex(int index) {
    state = PlayingSongsState(playlistId: state.playlistId, songs: [...state.songs], shuffled: state.shuffled, playingSongIndex: index);
  }

  void notifyPlayStarted({required Song song, required String playlistId, bool? shuffle}) {
    final songs = [...ref.read(playlistsProvider).playlists.get(playlistId).songs];
    if (shuffle ?? state.shuffled == true) {
      songs.shuffle(Random());
    } else {
      songs.sortSongs(playlistId, ref);
    }

    int index = 0;
    for (int i = 0; i < songs.length; i++) {
      var id = songs[i];
      if (id == song.id) {
        index = i;
        break;
      }
    }
    state = PlayingSongsState(playlistId: playlistId, songs: songs, shuffled: shuffle ?? state.shuffled, playingSongIndex: index);
  }

  void updateToNextSong() {
    int index = state.playingSongIndex;
    index++;
    if (index >= state.songs.length) {
      index = 0;
    }
    state = PlayingSongsState(playlistId: state.playlistId, songs: [...state.songs], shuffled: state.shuffled, playingSongIndex: index);
  }

  void updateToPreviousSong() {
    int index = state.playingSongIndex;
    index--;
    if (index < 0) {
      index = state.songs.length - 1;
    }
    state = PlayingSongsState(playlistId: state.playlistId, songs: [...state.songs], shuffled: state.shuffled, playingSongIndex: index);
  }

  void updateTo(int index) {
    state = PlayingSongsState(playlistId: state.playlistId, songs: [...state.songs], shuffled: state.shuffled, playingSongIndex: index);
  }
}

final playingSongsProvider = NotifierProvider<PlayingSongsNotifier, PlayingSongsState>(PlayingSongsNotifier.new);

class VolumeNotifier extends Notifier<double> {
  @override
  double build() => 1;

  void set(double value) => state = value;
}

final volumeProvider = NotifierProvider<VolumeNotifier, double>(VolumeNotifier.new);

class DurationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

final durationProvider = NotifierProvider<DurationNotifier, int>(DurationNotifier.new);

class PositionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

final positionProvider = NotifierProvider<PositionNotifier, int>(PositionNotifier.new);

class IsPlayingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final isPlayingProvider = NotifierProvider<IsPlayingNotifier, bool>(IsPlayingNotifier.new);

class PlayModeNotifier extends Notifier<int> {
  @override
  int build() => repeatAll;

  void set(int value) => state = value;
}

final playModeProvider = NotifierProvider<PlayModeNotifier, int>(PlayModeNotifier.new);