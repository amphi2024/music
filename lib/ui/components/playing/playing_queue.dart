import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/services/player_service.dart';
import 'package:music/ui/components/playing/playing_queue_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayingQueue extends ConsumerWidget {
  final Color? textColor;

  const PlayingQueue({super.key, this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idList = ref.watch(playingSongsProvider).songs;
    final songs = ref.watch(songsProvider);
    final playingSongId = playerService.playingSongId(ref);

    return ScrollablePositionedList.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          bottom: MediaQuery.paddingOf(context).bottom
        ),
        initialScrollIndex: idList.indexOf(playingSongId),
        itemCount: idList.length,
        itemBuilder: (context, index) {
          return PlayingQueueItem(
              song: songs.get(idList[index]),
              index: index,
              textColor: textColor
          );
        });
  }
}