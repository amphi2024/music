import 'package:flutter/material.dart';
import 'package:music/models/player_service.dart';

class ShuffleIcon extends StatelessWidget {
  const ShuffleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final shuffled = playerService.shuffled;
    return Icon(
        shuffled ? Icons.shuffle : Icons.shuffle,
        color: shuffled ? null : Theme.of(context).dividerColor
    );
  }
}
