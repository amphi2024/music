
import 'package:flutter/material.dart';

import 'package:music/ui/components/playing/playing_lyrics.dart';

class MobilePlayingLyrics extends StatefulWidget {

  final void Function() onRemove;
  const MobilePlayingLyrics({super.key, required this.onRemove});

  @override
  State<MobilePlayingLyrics> createState() => _PlayingLyricsState();
}

class _PlayingLyricsState extends State<MobilePlayingLyrics> with SingleTickerProviderStateMixin{

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
      opacity: animation,
      child: GestureDetector(
        onTap: () async {
          await controller.reverse();
          widget.onRemove();
        },
        child: Material(
          color: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
          child: Padding(
            padding: EdgeInsets.only(left: 15, right: 50),
            child: PageStorage(
              bucket: PageStorageBucket(),
              child: PlayingLyrics(
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: MediaQuery.paddingOf(context).bottom),
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}