import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../models/player_service.dart';
import '../../../utils/duration_converter.dart';

class DesktopPlayControls extends StatefulWidget {

  final void Function(void Function()) setState;
  final double length;
  final double position;
  const DesktopPlayControls({super.key, required this.setState, required this.length, required this.position});

  @override
  State<DesktopPlayControls> createState() => _DesktopPlayControlsState();
}

class _DesktopPlayControlsState extends State<DesktopPlayControls> {

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
                icon: Icon(Icons.fast_rewind, size: 20),
                onPressed: () {
                  playerService.playPrevious();
                }),
            IconButton(
                icon: Icon(
                    playerService.player.state ==
                        PlayerState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 30),
                onPressed: () {
                  playerService.togglePlay();
                }),
            IconButton(
                icon: Icon(
                  Icons.fast_forward,
                  size: 20,
                ),
                onPressed: () {
                  playerService.playNext();
                })
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DurationConverter.convertedDuration(widget.position),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Slider(
                    min: 0,
                    max: widget.length,
                    value: widget.position,
                    onChanged: (d) {
                      setState(() {
                        playerService.player.seek(
                            Duration(milliseconds: d.toInt()));
                      });
                    }),
              ),
            ),
            Text(
              DurationConverter.convertedDuration(widget.length),
            ),
          ],
        )
      ],
    );
  }
}
