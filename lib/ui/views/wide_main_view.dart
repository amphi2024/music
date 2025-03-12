import 'package:amphi/widgets/menu/popup/show_menu.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/navigation_menu.dart';
import 'package:music/ui/components/playing/desktop_playing_bar.dart';
import 'package:music/ui/fragments/songs_fragment.dart';

import '../fragments/albums_fragment.dart';
import '../fragments/artists_fragment.dart';
import '../fragments/genres_fragment.dart';

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



  List<Widget> fragments = [
    SongsFragment(),
    ArtistsFragment(),
    AlbumsFragment(),
    GenresFragment()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 200,
            right: 0,
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  Text("Songs"),
                  Expanded(
                      child: MoveWindow()
                  ),
                  // PopupMenuButton(icon: Icon(Icons.add_circle_outline),
                  //     itemBuilder: (context) {
                  //   return [
                  //     PopupMenuItem(child: Text("Song"), onTap: () {}),
                  //     PopupMenuItem(child: Text("Playlist"), onTap: () {}),
                  //   ];
                  // }),
                  // IconButton(onPressed: () {}, icon: Icon(Icons.lyrics)),
                  // IconButton(onPressed: () {}, icon: Icon(Icons.list)),
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
          DesktopPlayingBar(),
          NavigationMenu(),
          AnimatedPositioned(
              left: 200,
              top: 50,
              bottom: 80,
              right: 0,
              duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint, child: fragments[appState.fragmentIndex])
        ],
      ),
    );
  }
}
