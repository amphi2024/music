
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/menu/desktop_floating_menu.dart';
import 'package:music/ui/components/navigation_menu.dart';
import 'package:music/ui/components/playing/desktop_playing_bar.dart';
import 'package:music/ui/fragments/songs_fragment.dart';

import '../../channels/app_method_channel.dart';
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

  final titles = [
    "Songs",
    "Artists",
    "Albums",
    "Genres"
  ];

   final List<Widget> fragments = [
    SongsFragment(),
    ArtistsFragment(),
    AlbumsFragment(),
    GenresFragment()
  ];

  @override
  void initState() {
    appState.setMainViewState = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);

    return PopScope(
      canPop: !appState.floatingMenuShowing,
      onPopInvokedWithResult: (didPop, result) {
        if(appState.floatingMenuShowing) {
          setState(() {
            appState.floatingMenuShowing = false;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          if(appState.floatingMenuShowing) {
            setState(() {
              appState.floatingMenuShowing = false;
            });
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
              toolbarHeight: 0 // This is needed to change the status bar text (icon) color on Android
          ),
          body: Stack(
            children: [
              AnimatedPositioned(
                  left: 200,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint, child: fragments[appState.fragmentIndex]),
              Positioned(
                top: 0,
                left: 200,
                right: 0,
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow(child: FragmentTitle(title: titles[appState.fragmentIndex],))),
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
              DesktopPlayingBar(song: playerService.nowPlaying(),),
              DesktopFloatingMenu()
            ],
          ),
        ),
      ),
    );
  }
}
