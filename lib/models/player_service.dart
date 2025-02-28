import 'package:audioplayers/audioplayers.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';

import 'app_state.dart';
import 'music/music.dart';

final playerService = PlayerService.getInstance();

class PlayerService {
  static final PlayerService _instance = PlayerService();
  static PlayerService getInstance() => _instance;

  final player = AudioPlayer();

  String playlistKey = "";
  Playlist get playlist => appStorage.playlists[playlistKey] ?? Playlist();
  int index = 0;

  Music nowPlaying() {
    if(playlist.queue.isEmpty || playlist.queue.length <= index) {
      return Music();
    }
    else {
      return appStorage.music[playlist.queue[index]] ?? Music();
    }
  }

  void setMusic({required Music music, required int i}) {
    var musicFilePath = music.musicFilePath();
    if(musicFilePath != null) {
      appState.setMainViewState(() {
        playerService.playlistKey = "";
        playerService.index = i;

        playerService.player.setSource(DeviceFileSource(
            musicFilePath
        ));
      });
    }
  }

  void togglePlay(void Function(bool) changeState) {
    if (playerService.player.state ==
        PlayerState.playing) {
      playerService.player.pause();
      changeState(false);
    } else {
      playerService.player.resume();
      changeState(true);
    }

  }
}