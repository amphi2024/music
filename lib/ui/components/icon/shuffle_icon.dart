import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playing_state_provider.dart';

class ShuffleIcon extends ConsumerWidget {

  final double? size;

  const ShuffleIcon({super.key, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shuffled = ref.watch(playingSongsProvider).shuffled;
    return Icon(Icons.shuffle,
      color: shuffled ? Theme.of(context).highlightColor : Theme
          .of(context)
          .disabledColor,
      size: size,
    );
  }
}
