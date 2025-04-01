import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';
import 'package:music/utils/duration_converter.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/player_service.dart';

class PlayControls extends StatefulWidget {

  const PlayControls({super.key});

  @override
  State<PlayControls> createState() => _PlayControlsState();
}

class _PlayControlsState extends State<PlayControls> {

  void playbackListener(position) {
    setState(() {

    });
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
    var themeData = Theme.of(context);
    var textTheme = themeData.textTheme;

    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  playerService
                      .nowPlaying()
                      .title
                      .byContext(context),
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
            ),
            Center(
              child: Text(
                playerService
                    .nowPlaying()
                    .artist
                    .name
                    .byContext(context),
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
                child: Slider(
                    min: 0,
                    max: playerService.musicDuration.toDouble(),
                    value: playerService.playbackPosition.toDouble(),
                  onChanged: (d) {
                    setState(() {
                      playerService.playbackPosition = d.toInt();
                    });
                  },
                  onChangeEnd: (d) {
                    appMethodChannel.applyPlaybackPosition(d.toInt());
                  },),
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationConverter.convertedDuration(playerService.playbackPosition),
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    DurationConverter.convertedDuration(playerService.musicDuration),
                    style: textTheme.bodyMedium,
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 15),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.fast_rewind, size: 45),
                  onPressed: () {
                    playerService.playPrevious(Localizations.localeOf(context).languageCode);
                  }),
              IconButton(
                  icon: Icon(
                      playerService.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 60),
                  onPressed: ()  {
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
                    size: 45,
                  ),
                  onPressed: () {
                    playerService.playNext(Localizations.localeOf(context).languageCode);
                  })
            ],
          ),
        ),
      ],
    );
  }
}