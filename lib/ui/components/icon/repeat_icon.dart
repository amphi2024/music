import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';

class RepeatIcon extends ConsumerWidget {
  final double? size;

  const RepeatIcon({super.key, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playMode = ref.watch(playModeProvider);
    return Icon(
      playMode == repeatOne ? Icons.repeat_one : Icons.repeat,
      color: playMode == playOnce ? Theme.of(context).iconTheme.color : Theme.of(context).highlightColor,
      size: size,
    );
  }
}
