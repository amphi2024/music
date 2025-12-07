import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/ui/components/icon/repeat_icon.dart';

import '../../../channels/app_method_channel.dart';
import '../../../services/player_service.dart';
import '../../../utils/duration_converter.dart';
import '../icon/shuffle_icon.dart';

class DesktopPlayControls extends ConsumerWidget {
  const DesktopPlayControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final duration = ref.watch(durationProvider);
    final position = ref.watch(positionProvider);

    final resumeButton = IconButton(
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 25),
        onPressed: () {
          if (isPlaying) {
            appMethodChannel.pauseMusic();
            ref.read(isPlayingProvider.notifier).set(false);
          } else {
            appMethodChannel.resumeMusic();
            ref.read(isPlayingProvider.notifier).set(true);
          }
        });

    if (MediaQuery.of(context).size.width < 800) {
      return resumeButton;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: ShuffleIcon(size: 15),
                onPressed: () {
                  toggleShuffle(ref);
                }),
            IconButton(
                icon: Icon(Icons.fast_rewind, size: 15),
                onPressed: () {
                  playPrevious(ref);
                }),
            resumeButton,
            IconButton(
                icon: Icon(
                  Icons.fast_forward,
                  size: 15,
                ),
                onPressed: () {
                  playNext(ref);
                }),
            IconButton(
                icon: RepeatIcon(size: 15),
                onPressed: () {
                  togglePlayMode(ref);
                }),
          ],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DurationConverter.convertedDuration(position),
                style: TextStyle(fontSize: 13),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 0, top: 0),
                  child: Slider(
                    min: 0,
                    max: duration.toDouble(),
                    value: position.toDouble(),
                    onChanged: (d) {
                      ref.read(positionProvider.notifier).set(d.toInt());
                    },
                    onChangeEnd: (d) {
                      appMethodChannel.applyPlaybackPosition(d.toInt());
                    },
                  ),
                ),
              ),
              Text(
                DurationConverter.convertedDuration(duration),
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        )
      ],
    );
  }
}
