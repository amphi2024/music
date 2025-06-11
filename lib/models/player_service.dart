import 'dart:io';
import 'dart:math';

import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_storage.dart';

import 'app_state.dart';
import 'music/song.dart';

const repeatAll = 0;
const repeatOne = 1;
const playOnce = 2;

final playerService = PlayerService.getInstance();

class PlayerService {
  static final PlayerService _instance = PlayerService();
  static PlayerService getInstance() => _instance;

  List<String> songs = [];
  int index = 0;
  String playlistId = "";
  String playingSongId = "";
  int musicDuration = 0;
  int playbackPosition = 0;
  bool isPlaying = false;
  double volume = 1;
  bool shuffled = false;
  int playMode = repeatAll;

  void togglePlayMode() {
    playMode++;
    if(playMode > playOnce) {
      playMode = 0;
    }
    if(Platform.isAndroid || Platform.isIOS) {
      appMethodChannel.syncPlaylistState();
    }
  }

  void toggleShuffle() {
    if(shuffled) {
      shuffled = false;
      songs.sortSongList(appCacheData.sortOption(playlistId));
    }
    else {
      shuffled = true;
      Random random = Random();
      songs.shuffle(random);
    }
    syncPlaylistState();
  }

  void syncPlaylistState() {
    for(int i = 0 ; i < songs.length; i++) {
      if(songs[i] == playingSongId) {
        index = i; // Sync index of playing song
      }
    }
    if(Platform.isAndroid || Platform.isIOS) {
      appMethodChannel.syncPlaylistState();
    }
  }

  Song nowPlaying() {
    if(songs.isEmpty || songs.length <= index) {
      return Song();
    }
    else {
      return appStorage.songs[playingSongId] ?? Song();
    }
  }

  Future<void> startPlay({required Song song, String? localeCode, required String playlistId, bool playNow = true, bool shuffle = false}) async {
    appCacheData.lastPlayedPlaylistId = playlistId;
    appCacheData.lastPlayedSongId = song.id;
    appCacheData.save();

    this.playlistId = playlistId;
    songs.clear();
    songs.addAll(appStorage.playlists.get(playlistId).songs.map((e) => e as String));

    if(shuffle) {
      shuffled = true;
      Random random = Random();
      songs.shuffle(random);
    }
    else {
      songs.sortSongList(appCacheData.sortOption(playlistId));
    }

      index = 0;
      for(int i = 0; i < songs.length; i++) {
        var id = songs[i];
        if(id == song.id) {
          index = i;
          break;
        }
      }
      playingSongId = songs[index];
      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }

      await appMethodChannel.setMediaSource(song: song, playNow: playNow);
      if(Platform.isAndroid || Platform.isIOS) {
        await appMethodChannel.syncPlaylistState();
      }
      musicDuration = await appMethodChannel.getMusicDuration();
  }

  Future<void> playPrevious(String? localeCode) async {
    playerService.index--;
    if(index < 0) {
      index = songs.length - 1;
    }
    playingSongId = songs[index];

      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }
      appState.setState(() {

      });
      await appMethodChannel.setMediaSource(song: nowPlaying(), playNow: isPlaying);
      appCacheData.lastPlayedSongId = playingSongId;
      appCacheData.save();

    if(Platform.isAndroid || Platform.isIOS) {
      await appMethodChannel.syncMediaSourceToNative();
    }
  }

  Future<void> playNext(String? localeCode) async {

    index++;
    if(index >= songs.length) {
      index = 0;
    }
    playingSongId = songs[index];

      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }

    appState.setState(() {

    });
      await appMethodChannel.setMediaSource(song: nowPlaying(), playNow: isPlaying);
    appCacheData.lastPlayedSongId = playingSongId;
    appCacheData.save();

    if(Platform.isAndroid || Platform.isIOS) {
      await appMethodChannel.syncMediaSourceToNative();
    }
  }

  Future<void> pauseMusicIfPlaying() async {
    if(await appMethodChannel.isMusicPlaying()) {
    await appMethodChannel.pauseMusic();
    }
  }
  Future<void> playAt(int i) async {
    if(await appMethodChannel.isMusicPlaying()) {
      await appMethodChannel.pauseMusic();
    }
    index = i;
    playingSongId = songs[i];
      await appMethodChannel.setMediaSource(song: nowPlaying(), playNow: isPlaying);
      await appMethodChannel.resumeMusic();
      musicDuration = await appMethodChannel.getMusicDuration();
     appState.setState(() {});

    if(Platform.isAndroid || Platform.isIOS) {
      await appMethodChannel.syncMediaSourceToNative();
    }
  }

}