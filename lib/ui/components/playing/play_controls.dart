import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/song.dart';
import 'package:music/utils/duration_converter.dart';

import '../../../models/player_service.dart';

class PlayControls extends StatelessWidget {

  final void Function(void Function()) setState;
  final double length;
  final double position;
  const PlayControls({super.key, required this.setState, required this.length, required this.position});

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
                      .byLocale(context),
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
                    .byLocale(context),
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
                    max: length,
                    value: position,
                    onChanged: (d) {
                      setState(() {
                        playerService.player.seek(
                            Duration(milliseconds: d.toInt()));
                      });
                    }),
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationConverter.convertedDuration(position),
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    DurationConverter.convertedDuration(length),
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
                    playerService.playPrevious();
                  }),
              IconButton(
                  icon: Icon(
                      playerService.player.state ==
                          PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 60),
                  onPressed: () {
                    playerService.togglePlay();
                  }),
              IconButton(
                  icon: Icon(
                    Icons.fast_forward,
                    size: 45,
                  ),
                  onPressed: () {
                    playerService.playNext();
                  })
            ],
          ),
        ),
      ],
    );
  }
}