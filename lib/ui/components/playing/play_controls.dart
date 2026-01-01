import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/ui/components/icon/repeat_icon.dart';
import 'package:music/ui/components/icon/shuffle_icon.dart';
import 'package:music/ui/components/seekbar.dart';
import 'package:music/utils/duration_converter.dart';
import 'package:music/utils/localized_title.dart';

import '../../../services/player_service.dart';

class PlayControls extends ConsumerWidget {
  const PlayControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;
    final song = ref.watch(playingSongsProvider.notifier).playingSong();
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  song.title.toLocalized(),
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
            ),
            Center(
              child: Text(
                artists.localizedName(),
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: SeekBar(
                  value: position,
                  max: duration,
                  onChanged: (value) {
                    ref.read(positionProvider.notifier).set(value);
                  },
                  onChangeEnd: (value) {
                    playerService.applyPlaybackPosition(value);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationConverter.convertedDuration(position),
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    DurationConverter.convertedDuration(duration),
                    style: textTheme.bodyMedium,
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery
              .of(context)
              .padding
              .bottom + 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: ShuffleIcon(size: 25),
                  onPressed: () {
                    playerService.toggleShuffle(ref);
                  }),
              IconButton(
                  icon: Icon(Icons.fast_rewind, size: 35),
                  onPressed: () {
                    playerService.playPrevious(ref);
                  }),
              IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
                  onPressed: () {
                    if (isPlaying) {
                      playerService.pause();
                      ref.read(isPlayingProvider.notifier).set(false);
                    } else {
                      playerService.resume();
                      ref.read(isPlayingProvider.notifier).set(true);
                    }
                  }),
              IconButton(
                  icon: Icon(
                    Icons.fast_forward,
                    size: 35,
                  ),
                  onPressed: () {
                    playerService.playNext(ref);
                  }),
              IconButton(
                  icon: RepeatIcon(size: 25),
                  onPressed: () {
                    playerService.togglePlayMode(ref);
                  })
            ],
          ),
        ),
      ],
    );
  }
}
