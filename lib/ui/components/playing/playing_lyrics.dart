import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/utils/lyrics_scroll.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../channels/app_method_channel.dart';

class PlayingLyrics extends ConsumerStatefulWidget {

  final void Function() onRemove;

  const PlayingLyrics({super.key, required this.onRemove});

  @override
  ConsumerState<PlayingLyrics> createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends ConsumerState<PlayingLyrics> {
  double opacity = 0;
  bool following = true;
  final scrollController = ItemScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 0.5;
      });
      ref.listen(positionProvider, (prev, position) {
        scrollToCurrentLyric(ref: ref, position: position, scrollController: scrollController);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Lyrics lyrics = ref.watch(playingSongsProvider.notifier).playingSong().playingFile()
        .lyrics;
    final List<LyricLine> lines = lyrics.getLinesByLocale(context);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);

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
                      if (line.startsAt <= position &&
                          line.endsAt >= duration) {
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
