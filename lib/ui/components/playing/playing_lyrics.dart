
import 'package:flutter/material.dart';
import 'package:music/models/player_service.dart';

import '../../../channels/app_method_channel.dart';

class PlayingLyrics extends StatefulWidget {
  const PlayingLyrics({super.key});

  @override
  State<PlayingLyrics> createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends State<PlayingLyrics> {

  void playbackListener(int position) {

      setState(() {

      });

  }

  @override
  void dispose() {
    appMethodChannel.playbackListeners.remove(playbackListener);
    super.dispose();
  }

  @override
  void initState() {
    appMethodChannel.playbackListeners.add(playbackListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lyrics = playerService.nowPlaying().playingFile().lyrics;
    var lines = lyrics.getLinesByLocale(context);

    return ListView.builder(
      itemCount: lines.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var focused = false;
        var line = lines[index];
          if(line.startsAt <= playerService.playbackPosition && line.endsAt >= playerService.playbackPosition) {
            focused = true;
          }
        return Text(
            lines[index].text,
          maxLines: 5,
          style: TextStyle(
            fontSize: 20,
            color: focused ? Theme.of(context).highlightColor : null,
            fontWeight: focused ? FontWeight.bold : null
          ),
        );
      },

    );
  }
}
