import 'package:flutter/material.dart';

class PlayingBar extends StatefulWidget {
  const PlayingBar({super.key});

  @override
  State<PlayingBar> createState() => _PlayingBarState();
}

class _PlayingBarState extends State<PlayingBar> {
  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return AnimatedPositioned(
      left: 10,
      right: 10,
      top: mediaQuery.size.height - 150,
      bottom: 80,
        curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
    child: GestureDetector(
      onPanUpdate: (d) {
        print("object");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red
        ),
      ),
    ));
  }
}