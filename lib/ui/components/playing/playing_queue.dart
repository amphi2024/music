import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/playing/playing_queue_item.dart';

class PlayingQueue extends StatelessWidget {
  final Color? textColor;
  const PlayingQueue({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    var playingQueue = playerService.songs;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: playingQueue.length,
        itemBuilder: (context, index) {
      return PlayingQueueItem(
          song: appStorage.songs[playingQueue[index]] ?? Song(),
        index: index,
          textColor: textColor
      );
    });
  }
}
