import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/ui/components/playing/connected_devices.dart';
import 'package:music/ui/components/playing/desktop_playing_lyrics.dart';
import 'package:music/ui/components/playing/playing_queue.dart';

class DesktopFloatingMenu extends StatefulWidget {
  const DesktopFloatingMenu({super.key});

  @override
  State<DesktopFloatingMenu> createState() => _DesktopFloatingMenuState();
}

class _DesktopFloatingMenuState extends State<DesktopFloatingMenu> {

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final showing = appState.floatingMenuShowing;

    return AnimatedPositioned(
      right: showing ? 15 : -300,
      top: 55,
      bottom: 95,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (d.delta.dx > 3) {
            appState.setMainViewState(() {
              appState.floatingMenuShowing = false;
            });
          }
        },
        child: Container(
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]),
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: [
                    DesktopPlayingLyrics(),
                    ConnectedDevices(),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: PlayingQueue(),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onLongPress: () {
                        setState(() {
                          appState.autoScrollLyrics = !appState.autoScrollLyrics;
                        });
                      },
                      onPressed: () {
                    setState(() {
                      index = 0;
                    });
                  }, icon: Icon(Icons.lyrics, color: appState.autoScrollLyrics ? null : Theme.of(context).disabledColor)),
                  IconButton(onPressed: () {
                    setState(() {
                      index = 1;
                    });
                  }, icon: Icon(Icons.devices)),
                  IconButton(onPressed: () {
                    setState(() {
                      index = 2;
                    });
                  }, icon: Icon(Icons.list))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
