import 'package:flutter/material.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/player_service.dart';
import '../../../utils/duration_converter.dart';

class DesktopPlayControls extends StatefulWidget {

  final void Function(void Function()) setState;
  const DesktopPlayControls({super.key, required this.setState});

  @override
  State<DesktopPlayControls> createState() => _DesktopPlayControlsState();
}

class _DesktopPlayControlsState extends State<DesktopPlayControls> {

  bool changingPosition = false;

  void playbackListener(int position) {
    if(!changingPosition) {
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    appMethodChannel.playbackListeners.remove(playbackListener);
    super.dispose();
  }

  @override
  void initState() {
    appMethodChannel.playbackListeners.add(playbackListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.shuffle, size: 20),
                onPressed: () {
                  playerService.playPrevious(Localizations.localeOf(context).languageCode);
                }),
            IconButton(
                icon: Icon(Icons.fast_rewind, size: 20),
                onPressed: () {
                  playerService.playPrevious(Localizations.localeOf(context).languageCode);
                }),
            IconButton(
                icon: Icon(
                    playerService.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 30),
                onPressed: () {
                  if(playerService.isPlaying) {
                    appMethodChannel.pauseMusic();
                    if(mounted) {
                      setState(() {
                        playerService.isPlaying = false;
                      });
                    }
                  }
                  else {
                    appMethodChannel.resumeMusic();
                    if(mounted) {
                      setState(() {
                        playerService.isPlaying = true;
                      });
                    }
                  }
                }),
            IconButton(
                icon: Icon(
                  Icons.fast_forward,
                  size: 20,
                ),
                onPressed: () {
                  playerService.playNext(Localizations.localeOf(context).languageCode);
                }),
            IconButton(
                icon: Icon(Icons.loop, size: 20),
                onPressed: () {
                  playerService.playPrevious(Localizations.localeOf(context).languageCode);
                }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DurationConverter.convertedDuration(playerService.playbackPosition),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Slider(
                    min: 0,
                    max: playerService.musicDuration.toDouble(),
                    value: playerService.playbackPosition.toDouble(),
                    onChangeStart: (d) {
                      changingPosition = true;
                    },
                    onChanged: (d) {
                      setState(() {
                        playerService.playbackPosition = d.toInt();
                      });
                    },
                  onChangeEnd: (d) {
                    appMethodChannel.applyPlaybackPosition(d.toInt());
                    changingPosition = false;
                  },
                    ),
              ),
            ),
            Text(
              DurationConverter.convertedDuration(playerService.musicDuration),
            ),
          ],
        )
      ],
    );
  }
}
