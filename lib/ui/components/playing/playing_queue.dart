import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/playing/playing_queue_item.dart';
import 'package:music/ui/components/repeat_icon.dart';
import 'package:music/ui/components/shuffle_icon.dart';

class PlayingQueue extends StatelessWidget {
  const PlayingQueue({super.key});

  @override
  Widget build(BuildContext context) {
    var playingQueue = playerService.playlist.songs;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: playingQueue.length,
        itemBuilder: (context, index) {
      return PlayingQueueItem(
          song: appStorage.songs[playingQueue[index]] ?? Song(),
        index: index,
      );
    });
  }
}
