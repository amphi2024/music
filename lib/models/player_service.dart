import 'package:amphi/models/app.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';

import 'app_state.dart';
import 'music/song.dart';

final playerService = PlayerService.getInstance();

class PlayerService {
  static final PlayerService _instance = PlayerService();
  static PlayerService getInstance() => _instance;

  final player = AudioPlayer();

  String playlistKey = "";
  Playlist get playlist => appStorage.playlists[playlistKey] ?? Playlist();
  int index = 0;
  bool get isPlaying => player.state == PlayerState.playing;

  Song nowPlaying() {
    if(playlist.queue.isEmpty || playlist.queue.length <= index) {
      return Song();
    }
    else {
      return appStorage.songs[playlist.queue[index]] ?? Song();
    }
  }

  Future<void> startPlay({required Song song, required int i}) async {
    var songFilePath = song.songFilePath();
    if(songFilePath != null) {
      playerService.playlistKey = "";
      playerService.index = i;
      playerService.player.setSource(DeviceFileSource(
          songFilePath
      ));
      await player.resume();
      appState.setState(() {

      });
    }
  }

  Future<void> playPrevious(void Function(bool, double) changeState) async {
    playerService.index--;
    if(index < 0) {
      index = playlist.queue.length - 1;
    }
    var songFilePath = playerService.nowPlaying().songFilePath();
    if(songFilePath != null) {
      await playerService.player.setSource(DeviceFileSource(songFilePath));
      await playerService.player.resume();
      var duration = (await playerService.player.getDuration())?.inMilliseconds.toDouble();
      if(duration != null && duration > 0) {
        changeState(true, duration);
      }
       else {
        playPrevious(changeState);
      }
    }
    else {
      playPrevious(changeState);
    }
  }

  Future<void> playNext(void Function(bool, double) changeState) async {
    if (playerService.player.state ==
        PlayerState.playing) {
      playerService.player.pause();
    }
    playerService.index++;
    if(index >= playlist.queue.length) {
      index = 0;
    }
    var songFilePath = playerService.nowPlaying().songFilePath();
    if(songFilePath != null) {
      await playerService.player.setSource(DeviceFileSource(songFilePath));
      await playerService.player.resume();
     var duration = await playerService.player.getDuration();
      if(duration != null) {
        changeState(true, duration.inMilliseconds.toDouble());
      }
      else {
        playNext(changeState);
      }
    }
    else {
      playNext(changeState);
    }
  }

  Future<void> togglePlay() async {
    if (playerService.player.state ==
        PlayerState.playing) {
      await playerService.player.pause();
      appState.setState(() {});
    } else {
      await playerService.player.resume();
      appState.setState(() {});
    }

  }
}