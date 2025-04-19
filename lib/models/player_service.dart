import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';

import 'app_state.dart';
import 'music/song.dart';

final playerService = PlayerService.getInstance();

class PlayerService {
  static final PlayerService _instance = PlayerService();
  static PlayerService getInstance() => _instance;

  String playlistKey = "";
  Playlist get playlist => appStorage.playlists[playlistKey] ?? Playlist();
  int index = 0;
  String playingSongId = "";
  int musicDuration = 0;
  int playbackPosition = 0;
  bool isPlaying = false;

  void shuffle() {
    playlist.shuffle();
    for(int i = 0 ; i < playlist.songs.length; i++) {
      if(playlist.songs[i] == playingSongId) {
        index = i;
      }
    }
  }

  Song nowPlaying() {
    if(playlist.songs.isEmpty || playlist.songs.length <= index) {
      return Song();
    }
    else {
      return appStorage.songs[playingSongId] ?? Song();
    }
  }

  Future<void> startPlay({required Song song, String? localeCode, required int i}) async {
    var songFilePath = song.songFilePath();
    if(songFilePath != null) {
      playlistKey = "";
      index = i;
      playingSongId = playlist.songs[index];
      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }
      await appMethodChannel.setMediaSource(song: song, playNow: true);
      musicDuration = await appMethodChannel.getMusicDuration();
    }
  }

  Future<void> playPrevious(String? localeCode) async {
    playerService.index--;
    if(index < 0) {
      index = playlist.songs.length - 1;
    }
    playingSongId = playlist.songs[index];
    var songFilePath = playerService.nowPlaying().songFilePath();
    if(songFilePath != null) {
      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }
      await appMethodChannel.setMediaSource(song: nowPlaying(), playNow: true);
      musicDuration = await appMethodChannel.getMusicDuration();
     appState.setState(() {
       isPlaying = true;
     });
    }
    else {
      playPrevious(localeCode);
    }
  }

  Future<void> playNext(String? localeCode) async {
    await pauseMusicIfPlaying();

    index++;
    if(index >= playlist.songs.length) {
      index = 0;
    }
    playingSongId = playlist.songs[index];
    var songFilePath = playerService.nowPlaying().songFilePath();
    if(songFilePath != null) {
      if(localeCode != null) {
        appMethodChannel.localeCode = localeCode;
      }
      await appMethodChannel.setMediaSource(song: nowPlaying());
      await appMethodChannel.resumeMusic();
      musicDuration = await appMethodChannel.getMusicDuration();
      appState.setState(() {
        isPlaying = true;
      });
    }
    else {
      playNext(localeCode);
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
    playingSongId = playlist.songs[i];
    var songFilePath = playerService.nowPlaying().songFilePath();
    if(songFilePath != null) {
      await appMethodChannel.setMediaSource(song: nowPlaying());
      await appMethodChannel.resumeMusic();
      musicDuration = await appMethodChannel.getMusicDuration();
     appState.setState(() {});
    }
  }

}