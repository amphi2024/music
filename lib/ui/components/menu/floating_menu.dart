import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/ui/components/menu/floating_menu_button.dart';

class FloatingMenu extends StatelessWidget {
  final bool showing;
  final void Function() requestHide;

  const FloatingMenu(
      {super.key, required this.showing, required this.requestHide});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: showing ? 15 : -300,
      top: 250,
      bottom: 150,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (d.delta.dx < -3) {
            requestHide();
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
          child: ListView(
            children: [
              FloatingMenuButton(
                  icon: Icons.music_note,
                  label: "Songs",
                  onPressed: () {
                    appState.setMainViewState(() {
                      appState.fragmentIndex = 0;
                    });
                  }),
              FloatingMenuButton(
                  icon: Icons.people,
                  label: "Artists",
                  onPressed: () {
                    appState.setMainViewState(() {
                      appState.fragmentIndex = 1;
                    });
                  }),
              FloatingMenuButton(
                  icon: Icons.album,
                  label: "Albums",
                  onPressed: () {
                    appState.setMainViewState(() {
                      appState.fragmentIndex = 2;
                    });
                  }),
              FloatingMenuButton(
                  icon: Icons.music_note,
                  label: "Genres",
                  onPressed: () {
                    appState.setMainViewState(() {
                      appState.fragmentIndex = 3;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
