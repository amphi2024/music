import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/playing_state_provider.dart';
import '../providers/songs_provider.dart';

void scrollToCurrentLyric({required WidgetRef ref, required int position, required ItemScrollController scrollController}) {
  final lyrics = ref.watch(songsProvider).get(ref.watch(playingSongsProvider.notifier).playingSongId()).playingFile().lyrics;
  final lines = lyrics.getLocalizedLines();
  for (int i = 0; i < lines.length; i ++) {
    if (lines[i].endsAt >= position && position >= lines[i].startsAt) {
      scrollController.scrollTo(index: i, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
      break;
    }
  }
}