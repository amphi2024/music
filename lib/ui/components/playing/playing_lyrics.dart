import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../models/music/lyrics.dart';
import '../../../providers/playing_state_provider.dart';
import '../../../services/player_service.dart';
import '../../../utils/lyrics_scroll.dart';

class PlayingLyrics extends ConsumerStatefulWidget {

  final EdgeInsets? padding;
  final Color? color;
  final double? fontSize;
  const PlayingLyrics({super.key, this.padding, this.color, this.fontSize});

  @override
  ConsumerState createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends ConsumerState<PlayingLyrics> {
  bool following = true;
  final scrollController = ItemScrollController();
  Timer? timer;
  final scrollOffsetListener = ScrollOffsetListener.create();

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    scrollOffsetListener.changes.listen((event) {
      if(event > 10) { // Stop following only on the user's gesture
        following = false;
        timer?.cancel();
        timer = Timer(Duration(seconds: 2), () async {
          following = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Lyrics lyrics = ref.watch(playingSongsProvider.notifier).playingSong().playingFile()
        .lyrics;
    final List<LyricLine> lines = lyrics.getLinesByLocale(context);
    final position = ref.watch(positionProvider);
    if(following) {
      ref.listen(positionProvider, (prev, position) {
        scrollToCurrentLyric(lyricLines: lines, position: position, scrollController: scrollController);
      });
    }

    return ScrollablePositionedList.builder(
      itemScrollController: scrollController,
      itemCount: lines.length,
      padding: widget.padding,
      scrollOffsetListener: scrollOffsetListener,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final line = lines[index];
        final focused = line.startsAt <= position && line.endsAt >= position;
        return SelectableText(
          onTap: () {
            playerService.applyPlaybackPosition(line.startsAt);
          },
          lines[index].text,
          minLines: 1,
          maxLines: 200,
          style: TextStyle(
              fontSize: widget.fontSize,
              color: focused ? Theme
                  .of(context)
                  .highlightColor : widget.color,
              fontWeight: focused ? FontWeight.bold : null
          ),
        );
      },
    );
  }
}