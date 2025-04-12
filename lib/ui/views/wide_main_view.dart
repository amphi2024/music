
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/ui/components/account/account_button.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/navigation_menu.dart';
import 'package:music/ui/components/playing/desktop_playing_bar.dart';
import 'package:music/ui/dialogs/settings_dialog.dart';
import 'package:music/ui/fragments/songs_fragment.dart';

import '../../channels/app_method_channel.dart';
import '../../models/app_storage.dart';
import '../dialogs/edit_playlist_dialog.dart';
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

  var titles = [
    "Songs",
    "Artists",
    "Albums",
    "Genres"
  ];

  List<Widget> fragments = [
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

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
              left: 200,
              top: 0,
              bottom: 80,
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
                  // Expanded(
                  //     child: MoveWindow()
                  // ),
                  AccountButton(),
                  PopupMenuButton(icon: Icon(Icons.add_circle_outline),
                      itemBuilder: (context) {
                    return [
                      PopupMenuItem(child: Text("Song"), onTap: () async {
                        appStorage.selectMusicFilesAndSave();
                      }),
                      PopupMenuItem(child: Text("Playlist"), onTap: () {
                        showDialog(context: context, builder: (context) {
                          return EditPlaylistDialog(onSave: (playlist) {
                            appState.setMainViewState(() {
                              appStorage.playlists[playlist.id] = playlist;
                            });
                          });
                        });
                      }),
                    ];
                  }),
                  IconButton(onPressed: () {
                    showDialog(context: context, builder: (context) => SettingsDialog());
                  }, icon: Icon(Icons.settings)),
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
        ],
      ),
    );
  }
}
