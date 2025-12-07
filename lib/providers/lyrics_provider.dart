import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LyricsState {
  final int index;
  final bool autoScroll;

  const LyricsState(this.index, this.autoScroll);
}

class LyricsStateNotifier extends Notifier<LyricsState> {

  final ItemScrollController scrollController = ItemScrollController();

  @override
  LyricsState build() {
    return LyricsState(0, true);
  }

  void sex() {
      if(state.autoScroll) {
        final lyrics = ref.watch(songsProvider).get(ref.watch(playingSongsProvider.notifier).playingSongId()).playingFile().lyrics;
        final lines = lyrics.getLocalizedLines();
        final position = ref.watch(positionProvider);
        for (int i = 0; i < lines.length; i ++) {
          if (lines[i].endsAt >= position && position >= lines[i].startsAt) {
            scrollController.scrollTo(index: i, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
            break;
          }
        }
      }
  }
}

final lyricsStateProvider = NotifierProvider(LyricsStateNotifier.new);