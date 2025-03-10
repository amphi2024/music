import 'package:flutter/material.dart';
import 'package:music/ui/components/playing/play_controls.dart';

class DesktopPlayingBar extends StatefulWidget {
  const DesktopPlayingBar({super.key});

  @override
  State<DesktopPlayingBar> createState() => _DesktopPlayingBarState();
}

class _DesktopPlayingBarState extends State<DesktopPlayingBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          height: 80,
      decoration: BoxDecoration(

      ),
          child: Stack(
            children: [

              // Positioned(
              //
              //     child: PlayControls())
            ],
          ),
    )
    );
  }
}
