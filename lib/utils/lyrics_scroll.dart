import 'package:flutter/animation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/music/lyrics.dart';

void scrollToCurrentLyric({required List<LyricLine> lyricLines, required int position, required ItemScrollController scrollController}) {
  for (int i = 0; i < lyricLines.length; i ++) {
    if (lyricLines[i].endsAt >= position && position >= lyricLines[i].startsAt) {
      scrollController.scrollTo(index: i, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
      break;
    }
  }
}