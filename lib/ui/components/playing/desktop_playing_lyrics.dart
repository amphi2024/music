import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/utils/lyrics_scroll.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/music/lyrics.dart';

class DesktopPlayingLyrics extends ConsumerStatefulWidget {
  const DesktopPlayingLyrics({super.key});

  @override
  ConsumerState<DesktopPlayingLyrics> createState() => _DesktopPlayingLyricsState();
}

class _DesktopPlayingLyricsState extends ConsumerState<DesktopPlayingLyrics> {
  final scrollController = ItemScrollController();
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = ref.watch(playingSongsProvider.notifier).playingSong().playingFile().lyrics;
    final List<LyricLine> lines = lyrics.getLinesByLocale(context);
    final position = ref.watch(positionProvider);

    ref.listen<int>(positionProvider, (prev, position) {
      scrollToCurrentLyric(ref: ref, scrollController: scrollController, position: position);
    });

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
            if (line.startsAt <= position &&
                line.endsAt >= position) {
              focused = true;
            }
            return GestureDetector(
              onTap: () {
                appMethodChannel.applyPlaybackPosition(line.startsAt);
              },
              child: Text(
                lines[index].text,
                //minLines: 1,
                maxLines: 200,
                style: TextStyle(
                    color: focused ? Theme
                        .of(context)
                        .highlightColor : null,
                    fontWeight: focused ? FontWeight.bold : null
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
