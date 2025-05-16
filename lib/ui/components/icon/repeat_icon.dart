import 'package:flutter/material.dart';
import 'package:music/models/player_service.dart';

class RepeatIcon extends StatelessWidget {

  final double? size;
  const RepeatIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(
        playerService.playMode == repeatOne ? Icons.repeat_one : Icons.repeat,
            color: playerService.playMode == playOnce ? Theme.of(context).dividerColor : null,
      size: size,
    );
  }
}