import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/playing/playing_queue_item.dart';

class PlayingQueue extends StatefulWidget {
  const PlayingQueue({super.key});

  @override
  State<PlayingQueue> createState() => _PlayingQueueState();
}

class _PlayingQueueState extends State<PlayingQueue> {
  @override
  Widget build(BuildContext context) {
    var playingQueue = playerService.playlist.queue;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: playingQueue.length,
              itemBuilder: (context, index) {
            return PlayingQueueItem(
                song: appStorage.songs[playingQueue[index]] ?? Song(),
              index: index,
            );
          }),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                setState(() {
                  playerService.shuffle();
                });
              }, child: Icon(Icons.shuffle)) ,
              ElevatedButton(onPressed: () {}, child: Icon(Icons.loop)) ,
              ElevatedButton(onPressed: () {}, child: Icon(Icons.loop)) ,
            ],
          ),
        ),
      ],
    );
  }
}
