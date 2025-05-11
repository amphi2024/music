import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/music/lyrics.dart';
import '../../../models/player_service.dart';

class DesktopPlayingLyrics extends StatefulWidget {
  const DesktopPlayingLyrics({super.key});

  @override
  State<DesktopPlayingLyrics> createState() => _DesktopPlayingLyricsState();
}

class _DesktopPlayingLyricsState extends State<DesktopPlayingLyrics> {
  double opacity = 0;
  bool following = true;
  final scrollController = ItemScrollController();

  void playbackListener(int position) {
    var lyrics = playerService.nowPlaying().playingFile().lyrics;
    var lines = lyrics.getLinesByLocale(context);
    setState(() {
      for(int i = 0; i < lines.length; i ++) {
        if(lines[i].endsAt >= position && position >= lines[i].startsAt) {
           scrollController.scrollTo(index: i, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    appMethodChannel.playbackListeners.remove(playbackListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    appMethodChannel.playbackListeners.add(playbackListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 0.5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Lyrics lyrics =  playerService.nowPlaying().playingFile().lyrics;
    List<LyricLine> lines = lyrics.getLinesByLocale(context);
    return Padding(
      padding: EdgeInsets.all(15),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ScrollablePositionedList.builder(
          itemScrollController: scrollController,
          itemCount: lines.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            var focused = false;
            var line = lines[index];
            if (line.startsAt <= playerService.playbackPosition &&
                line.endsAt >= playerService.playbackPosition) {
              focused = true;
            }
            return SelectableText(
              onTap: () {
                appMethodChannel.applyPlaybackPosition(line.startsAt);
              },
              lines[index].text,
              minLines: 1,
              maxLines: 200,
              style: TextStyle(
                  color: focused ? Theme
                      .of(context)
                      .highlightColor : null,
                  fontWeight: focused ? FontWeight.bold : null
              ),
            );
          },

        ),
      ),
    );
  }
}
