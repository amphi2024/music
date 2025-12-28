import 'package:flutter/material.dart';
import 'package:music/ui/components/playing/playing_lyrics.dart';

class DesktopPlayingLyrics extends StatelessWidget {
  const DesktopPlayingLyrics({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: PlayingLyrics(
            padding: EdgeInsets.zero
        ),
      ),
    );
  }
}