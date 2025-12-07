import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/playing/connected_devices.dart';
import 'package:music/ui/components/playing/desktop_playing_lyrics.dart';
import 'package:music/ui/components/playing/playing_queue.dart';

class DesktopFloatingMenu extends ConsumerStatefulWidget {
  const DesktopFloatingMenu({super.key});

  @override
  ConsumerState<DesktopFloatingMenu> createState() => _DesktopFloatingMenuState();
}

class _DesktopFloatingMenuState extends ConsumerState<DesktopFloatingMenu> {

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final showing = ref.watch(floatingMenuShowingProvider);

    return AnimatedPositioned(
      right: showing ? 15 : -300,
      top: 55,
      bottom: 95,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (d.delta.dx > 3) {
            ref.read(floatingMenuShowingProvider.notifier).set(false);
          }
        },
        child: Container(
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme
                  .of(context)
                  .cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme
                      .of(context)
                      .shadowColor,
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
                        // setState(() {
                        //   appState.autoScrollLyrics = !appState.autoScrollLyrics;
                        // });
                      },
                      onPressed: () {
                        setState(() {
                          index = 0;
                        });
                      }, icon: Icon(Icons.lyrics)),
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
