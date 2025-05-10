import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';

final appMethodChannel = AppMethodChannel.getInstance();

class AppMethodChannel extends MethodChannel {
  static final AppMethodChannel _instance = AppMethodChannel._internal("music_method_channel");

  AppMethodChannel._internal(super.name) {
    if (Platform.isWindows) {
      timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
        final position = await getPlaybackPosition();
        if (playerService.isPlaying) {
          await onPlaybackChanged(position);
          if (position + 50 >= playerService.musicDuration) {
            playerService.playNext(localeCode);
          }
        }
      });
    }
    setMethodCallHandler((call) async {
      switch (call.method) {
        case "on_playback_changed":
          final position = call.arguments["position"];
          await onPlaybackChanged(position);
          break;
        case "play_previous":
          playerService.playPrevious(localeCode);
          break;
        case "play_next":
          playerService.playNext(localeCode);
          break;
        case "on_pause":
          for (var fun in playbackListeners) {
            playerService.isPlaying = false;
            fun(playerService.playbackPosition);
          }
          break;
        case "on_resume":
          for (var fun in playbackListeners) {
            playerService.isPlaying = true;
            fun(playerService.playbackPosition);
          }
        default:
          break;
      }
    });
  }

  Future<void> onPlaybackChanged(int position) async {
    if (position <= playerService.musicDuration) {
      playerService.playbackPosition = position;
      if (position < 1500) {
        playerService.musicDuration = await getMusicDuration();
      }
      for (var fun in playbackListeners) {
        fun(playerService.playbackPosition);
      }
    } else {
      playerService.musicDuration = await appMethodChannel.getMusicDuration();
    }
  }

  static AppMethodChannel getInstance() => _instance;

  List<void Function(int)> playbackListeners = [];

  Timer? timer;
  int systemVersion = 0;
  bool needsBottomPadding = false;
  String? _localeCode;

  set localeCode(value) => _localeCode = value;

  String get localeCode => _localeCode ?? "default";

  void createDirectoryIfNotExists(String path) {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync();
    }
  }

  Future<Map> getMusicMetadata(String filePath) async {
    var result = await invokeMethod("get_music_metadata", {"path": filePath});
    if (result is Map) {
      return result;
    } else {
      return {};
    }
  }

  Future<List<int>> getAlbumCover(String filePath) async {
    if (!Platform.isWindows) {
      var result = await invokeMethod("get_album_cover", {"path": filePath});
      if (result is List && result.length > 4) {
        return result.map((e) {
          if (e is int) {
            return e;
          } else {
            return 0;
          }
        }).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  void setNavigationBarColor(Color color) {
    if (Platform.isAndroid) {
      invokeMethod("set_navigation_bar_color", {"color": color.value, "transparent_navigation_bar": appSettings.transparentNavigationBar});
    }
  }

  void getSystemVersion() async {
    systemVersion = await invokeMethod("get_system_version");
  }

  void configureNeedsBottomPadding() async {
    needsBottomPadding = await invokeMethod("configure_needs_bottom_padding");
  }

  Future<void> resumeMusic() async {
    await invokeMethod("resume_music");
  }

  Future<void> pauseMusic() async {
    await invokeMethod("pause_music");
  }

  Future<bool> isMusicPlaying() async {
    return await invokeMethod("is_music_playing");
  }

  Future<void> setVolume(double volume) async {
    await invokeMethod("set_volume", {"volume": volume});
  }

  Future<void> syncPlaylistState() async {
    List<Map<String, dynamic>> list = [];
    for (String songId in playerService.playlist.songs) {
      var song = appStorage.songs.get(songId);
      var songFile = song.playingFile();
      list.add({
        "media_file_path": songFile.mediaFilepath,
        "url": songFile.url,
        "title": song.title.byLocaleCode(localeCode),
        "artist": song.artist.name.byLocaleCode(localeCode),
        "album_cover_file_path": song.album.covers.firstOrNull,
        "song_id": song.id
      });
    }
    await invokeMethod("sync_playlist_state", {
      "list": list,
      "play_mode": playerService.playMode,
      "index": playerService.index
    });
  }

  Future<void> setMediaSource({required Song song, String? localeCode, bool playNow = true}) async {
    await invokeMethod("set_media_source", {
      "path": song.playingFile().mediaFilepath,
      "play_now": playNow,
      "title": song.title.byLocaleCode(this.localeCode),
      "artist": song.artist.name.byLocaleCode(this.localeCode),
      "album_cover": song.album.covers.firstOrNull ?? "",
      "url": song.playingFile().url,
      "token": appStorage.selectedUser.token
    });
  }

  Future<void> applyPlaybackPosition(int position) async {
    await invokeMethod("apply_playback_position", {"position": position});
  }

  Future<int> getMusicDuration() async {
    return await invokeMethod("get_music_duration");
  }

  Future<int> getPlaybackPosition() async {
    return await invokeMethod("get_playback_position");
  }
}
