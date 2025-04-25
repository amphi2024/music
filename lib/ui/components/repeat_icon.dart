import 'package:flutter/material.dart';
import 'package:music/models/player_service.dart';

class RepeatIcon extends StatelessWidget {
  const RepeatIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
        playerService.playMode == repeatOne ? Icons.repeat_one : Icons.repeat,
            color: playerService.playMode == playOnce ? Theme.of(context).dividerColor : null,
    );
  }
}