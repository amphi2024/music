import 'dart:io';
import 'package:flutter/services.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';

final appMethodChannel = AppMethodChannel.getInstance();

class AppMethodChannel extends MethodChannel {
  static final AppMethodChannel _instance = AppMethodChannel._internal("music_method_channel");
  AppMethodChannel._internal(super.name) {
    setMethodCallHandler((call) async {
      switch (call.method) {
        case "on_playback_changed":
          playerService.playbackPosition = call.arguments["position"];
          if(playerService.playbackPosition < playerService.musicDuration) {
            for (var fun in playbackListeners) {
              fun(playerService.playbackPosition);
            }
          }
          else {
            playerService.musicDuration = await appMethodChannel.getMusicDuration();
          }
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

  static AppMethodChannel getInstance() => _instance;

  List<void Function(int)> playbackListeners = [];

  int systemVersion = 0;
  bool needsBottomPadding = false;
  String? localeCode;

  void createDirectoryIfNotExists(String path) {
    Directory directory = Directory(path);
    if(!directory.existsSync()) {
      directory.createSync();
    }
  }

  Future<Map> getMusicMetadata(String filePath) async {
    var result = await invokeMethod("get_music_metadata", {"path": filePath});
    if(result is Map) {
      return result;
    }
    else {
      return {};
    }
  }

  Future<List<int>> getAlbumCover(String filePath) async {
    if(!Platform.isWindows) {
    var result = await invokeMethod("get_album_cover", {"path": filePath});
    if(result is List && result.length > 4) {
      return result.map((e) {
        if(e is int) {
         return e;
        }
        else {
          return 0;
        }
      }).toList();
    }
    else {
      return [];
    }
    }
    else {
      return [];
    }
  }

  void setNavigationBarColor(Color color) {
    if(Platform.isAndroid) {
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

  Future<void> setMediaSource({required Song song, String? localeCode, bool playNow = true}) async {
    await invokeMethod("set_media_source", {
      "path": song.songFilePath(),
      "play_now": playNow,
      "title": song.title.byLocaleCode(this.localeCode ?? "default"),
      "artist": song.artist.name.byLocaleCode(this.localeCode ?? "default"),
      "album_cover": song.album.covers.firstOrNull
    });
  }

  Future<void> applyPlaybackPosition(int position) async {
    await invokeMethod("apply_playback_position", {
      "position": position
    });
  }

  Future<int> getMusicDuration() async {
    return await invokeMethod("get_music_duration");
  }
}