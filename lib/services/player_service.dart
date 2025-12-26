import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' show Player, Media;
import 'package:music/channels/app_method_channel.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/media_file_path.dart';

import '../models/app_storage.dart';
import '../models/music/song.dart';
import '../providers/playing_state_provider.dart';

final playerService = PlayerService.getInstance();

class PlayerService {
  static final _instance = PlayerService();

  static PlayerService getInstance() => _instance;

  Player? player = Platform.isWindows || Platform.isMacOS || Platform.isLinux ? Player() : null;

  Future<void> startPlay({required Song song, required String playlistId, bool? shuffle, bool playNow = true, required WidgetRef ref}) async {
    startPlayFromPlaylist(song: song, playlist: ref.read(playlistsProvider).playlists.get(playlistId), ref: ref, playNow: playNow);
  }

  Future<void> startPlayFromPlaylist(
      {required Song song, required Playlist playlist, bool? shuffle, bool playNow = true, required WidgetRef ref}) async {
    if (song.id.isEmpty) {
      return;
    }
    appCacheData.lastPlayedPlaylistId = playlist.id;
    appCacheData.lastPlayedSongId = song.id;
    appCacheData.save();

    await setMediaSource(song: song, playNow: playNow, ref: ref);

    syncPlaylistState(ref);

    ref.read(playingSongsProvider.notifier).notifyPlayStarted(song: song, playlist: playlist, shuffle: shuffle);
    ref.read(isPlayingProvider.notifier).set(playNow);
  }

  Future<void> syncMediaSourceToNative(WidgetRef ref) async {
    await appMethodChannel.invokeMethod(
        "sync_media_source_to_native", {"index": ref.read(playingSongsProvider).playingSongIndex, "is_playing": ref.read(isPlayingProvider)});
  }

  Future<void> resume() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await player!.playOrPause();
    } else {
      await appMethodChannel.resumeMusic();
    }
  }

  Future<void> pause() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await player!.pause();
    } else {
      await appMethodChannel.pauseMusic();
    }
  }

  Future<bool> isPlaying() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return player!.state.playing;
    } else {
      return appMethodChannel.isMusicPlaying();
    }
  }

  Future<void> setVolume(double volume) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await player!.setVolume(volume);
    } else {
      appMethodChannel.setVolume(volume);
    }
  }

  Future<void> applyPlaybackPosition(int position) async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await player!.seek(Duration(milliseconds: position));
    } else {
      await appMethodChannel.applyPlaybackPosition(position);
    }
  }

  Future<int> getMusicDuration() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return player!.state.duration.inMilliseconds;
    } else {
      return appMethodChannel.getMusicDuration();
    }
  }

  Future<int> getPlaybackPosition() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return player!.state.position.inMilliseconds;
    } else {
      return appMethodChannel.getPlaybackPosition();
    }
  }

  Future<void> playNext(WidgetRef ref) async {
    ref.read(playingSongsProvider.notifier).updateToNextSong();
    final song = playingSong(ref);
    appCacheData.lastPlayedSongId = song.id;
    appCacheData.save();

    setMediaSource(song: playingSong(ref), ref: ref, playNow: ref.read(isPlayingProvider));

    if (Platform.isAndroid || Platform.isIOS) {
      await syncMediaSourceToNative(ref);
    }
  }

  void togglePlayMode(WidgetRef ref) {
    var playMode = ref.watch(playModeProvider);
    playMode++;
    if (playMode > playOnce) {
      playMode = 0;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      syncPlaylistState(ref);
    }
    ref.read(playModeProvider.notifier).set(playMode);
    appCacheData.playMode = playMode;
    appCacheData.save();
  }

  void toggleShuffle(WidgetRef ref) {
    final shuffled = ref.watch(playingSongsProvider).shuffled;
    if (shuffled) {
      appCacheData.shuffled = false;
    } else {
      appCacheData.shuffled = true;
    }
    ref.read(playingSongsProvider.notifier).setShuffled(appCacheData.shuffled);
    appCacheData.save();

    syncPlaylistState(ref);
  }

  Future<void> playPrevious(WidgetRef ref) async {
    ref.read(playingSongsProvider.notifier).updateToPreviousSong();
    final song = playingSong(ref);
    appCacheData.lastPlayedSongId = song.id;
    appCacheData.save();

    setMediaSource(song: playingSong(ref), ref: ref, playNow: ref.read(isPlayingProvider));

    if (Platform.isAndroid || Platform.isIOS) {
      await syncMediaSourceToNative(ref);
    }
  }

  Future<void> playAt(WidgetRef ref, int i) async {
    if (await isPlaying()) {
      await pause();
    }
    ref.read(playingSongsProvider.notifier).updateTo(i);
    await setMediaSource(song: playingSong(ref), ref: ref, playNow: ref.read(isPlayingProvider));
    if (Platform.isAndroid || Platform.isIOS) {
      await syncMediaSourceToNative(ref);
    }
  }

  Future<void> syncPlaylistState(WidgetRef ref) async {
    List<Map<String, dynamic>> list = [];
    for (String songId in currentPlaylist(ref).songs) {
      final song = ref.read(songsProvider).get(songId);
      final artists = ref.read(artistsProvider).getAll(song.artistIds);
      final album = ref.read(albumsProvider).get(song.albumId);
      final songFile = song.playingFile();
      list.add({
        "media_file_path": songMediaFilePath(song.id, songFile.filename),
        "url": "${appWebChannel.serverAddress}/music/songs/${songId}/files/${songFile.id}",
        "title": song.title.toLocalized(),
        "artist": artists.localizedName(),
        "album_cover_file_path": album.covers.firstOrNull,
        "song_id": song.id
      });
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await appMethodChannel.invokeMethod(
          "sync_playlist_state", {"list": list, "play_mode": ref.read(playModeProvider), "index": ref.read(playingSongsProvider).playingSongIndex});
    }
  }

  Playlist currentPlaylist(WidgetRef ref) {
    return ref.read(playlistsProvider).playlists.get(ref.read(playingSongsProvider).playlistId);
  }

  String playingSongId(WidgetRef ref) {
    return ref.read(playingSongsProvider.notifier).playingSongId();
  }

  Song playingSong(WidgetRef ref) {
    return ref.read(songsProvider).get(playingSongId(ref));
  }

  Future<void> setMediaSource({required Song song, required WidgetRef ref, bool playNow = true}) async {
    final artists = ref.read(artistsProvider).getAll(song.artistIds);
    final album = ref.read(albumsProvider).get(song.albumId);
    song.setRandomFileIndex();
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (player!.state.playlist.medias.isNotEmpty) {
        await player!.remove(0);
      }
      if (song.availableOnOffline()) {
        await player!.open(Media(songMediaFilePath(song.id, song.playingFile().filename)), play: playNow);
      } else {
        await player!.open(
            Media("${appWebChannel.serverAddress}/music/songs/${song.id}/files/${song.playingFile().filename}",
                httpHeaders: {"Authorization": appStorage.selectedUser.token}),
            play: playNow);
      }
    } else {
      await appMethodChannel.invokeMethod("set_media_source", {
        "path": songMediaFilePath(song.id, song.playingFile().filename),
        "play_now": playNow,
        "title": song.title.toLocalized(),
        "artist": artists.localizedName(),
        "album_cover": album.coverIndex != null ? albumCoverPath(album.id, album.covers[album.coverIndex!]["filename"]) : "",
        "url": "${appWebChannel.serverAddress}/music/songs/${song.id}/files/${song.playingFile().filename}",
        "token": appStorage.selectedUser.token
      });
    }
  }
}