import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';

class PlayingLyrics extends StatefulWidget {
  const PlayingLyrics({super.key});

  @override
  State<PlayingLyrics> createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends State<PlayingLyrics> {

  int position = -1;

  @override
  void initState() {
    playerService.player.onPositionChanged.listen((duration) {
      setState(() {
        position = duration.inMilliseconds;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lyrics = playerService.nowPlaying().playingFile().lyrics;
    var lines = lyrics.getLinesByLocale(context);

    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        var focused = false;
        var line = lines[index];
          if(line.startsAt <= position && line.endsAt >= position) {
            focused = true;
          }
        return Text(
            lines[index].text,
          style: TextStyle(
            fontSize: 20,
            color: focused ? Theme.of(context).highlightColor : null
          ),
        );
      },

    );
  }
}
