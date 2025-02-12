import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/ui/components/navigation_menu.dart';
import 'package:music/ui/components/playing/desktop_playing_bar.dart';

class WideMainView extends StatefulWidget {
  const WideMainView({super.key});

  @override
  State<WideMainView> createState() => _WideMainViewState();
}

class _WideMainViewState extends State<WideMainView> {

  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 30,
              child: Row(
                children: [
                  Expanded(
                      child: MoveWindow()
                  ),
                  MinimizeWindowButton(),
                  appWindow.isMaximized
                      ? RestoreWindowButton(
                    onPressed: maximizeOrRestore,
                  )
                      : MaximizeWindowButton(
                    onPressed: maximizeOrRestore,
                  ),
                  CloseWindowButton()
                ],
              ),
            ),
          ),
          NavigationMenu(),
          DesktopPlayingBar()
        ],
      ),
    );
  }
}
