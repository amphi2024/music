
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

  bool following = true;

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
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 50, top: MediaQuery.paddingOf(context).top),
                  child: PageStorage(
                    bucket: PageStorageBucket(),
                    child: PlayingLyrics(
                      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: MediaQuery.paddingOf(context).bottom),
                      color: Colors.white,
                      fontSize: 30,
                      following: following,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                  right: 15,
                  child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                          style: IconButton.styleFrom(
                              backgroundColor: Color.fromARGB(150, 255, 255, 255),
                              shape: const CircleBorder()),
                          onPressed: () {
                            setState(() {
                              following = !following;
                            });
                          },
                          icon: Icon(
                            color: following ? Theme.of(context).floatingActionButtonTheme.focusColor : Theme.of(context).disabledColor,
                            Icons.sync,
                            size: 25,
                          ))))
            ],
          ),
        ),
      ),
    );
  }
}