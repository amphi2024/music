import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/ui/components/playing/playing_queue.dart';


class MobilePlayingQueue extends ConsumerStatefulWidget {

  final void Function() onRemove;

  const MobilePlayingQueue({super.key, required this.onRemove});

  @override
  ConsumerState<MobilePlayingQueue> createState() => _MobilePlayingQueueState();
}

class _MobilePlayingQueueState extends ConsumerState<MobilePlayingQueue> with SingleTickerProviderStateMixin {

  late final AnimationController controller = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 150),
      vsync: this
  );

  late final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut
  );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: GestureDetector(
        onTap: () async {
          await controller.reverse();
          widget.onRemove();
        },
        child: Material(
          color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: PageStorage(
                bucket: PageStorageBucket(),
                child: PlayingQueue(textColor: Colors.white)),
          ),
        ),
      ),
    );
  }
}
