import 'package:flutter/material.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/player_service.dart';

class PlayingLyrics extends StatefulWidget {

  final void Function() onRemove;
  const PlayingLyrics({super.key, required this.onRemove});

  @override
  State<PlayingLyrics> createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends State<PlayingLyrics> {
  double opacity = 0;
  bool following = true;
  final scrollController = ItemScrollController();

  void playbackListener(int position) {
    var lyrics = playerService.nowPlaying().playingFile().lyrics;
    var lines = lyrics.getLinesByLocale(context);
    setState(() {
      for(int i = 0; i < lines.length; i ++) {
        if(lines[i].endsAt >= position && position >= lines[i].startsAt) {
          scrollController.scrollTo(index: i, duration: Duration(milliseconds: 500), curve: Curves.easeOutQuint);
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        widget.onRemove();
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            opacity = 0;
          });
          widget.onRemove();
        },
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Color.fromRGBO(15, 15, 15, opacity),
            curve: Curves.easeOutQuint,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: opacity * 2,
              curve: Curves.easeOutQuint,
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: MediaQuery
                    .of(context)
                    .padding
                    .top, bottom: 0),
                child: PageStorage(
                  bucket: PageStorageBucket(),
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
                            fontSize: 30,
                            color: focused ? Theme
                                .of(context)
                                .highlightColor : Colors.white,
                            fontWeight: focused ? FontWeight.bold : null
                        ),
                      );
                    },

                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
