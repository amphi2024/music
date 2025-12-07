import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/media_file_path.dart';

final appMethodChannel = AppMethodChannel.getInstance();

class AppMethodChannel extends MethodChannel {
  static final AppMethodChannel _instance = AppMethodChannel._internal("music_method_channel");

  AppMethodChannel._internal(super.name);

  static AppMethodChannel getInstance() => _instance;

  int systemVersion = 0;

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
      invokeMethod("set_navigation_bar_color", {"color": color.toARGB32(), "transparent_navigation_bar": appSettings.transparentNavigationBar});
    }
  }

  void getSystemVersion() async {
    systemVersion = await invokeMethod("get_system_version");
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

  Future<void> setMediaSource({required Song song, String localeCode = "default", bool playNow = true}) async {
    await invokeMethod("set_media_source", {
      "path": songMediaFilePath(song.id, song.playingFile().filename),
      "play_now": playNow,
      "title": song.title.byLocaleCode(localeCode),
      // "artist": song.artist.name.byLocaleCode(localeCode),
      // "album_cover": song.album.covers.firstOrNull ?? "",
      "url": "${appWebChannel.serverAddress}/music/songs/${song.id}/${song.playingFile().filename}",
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
