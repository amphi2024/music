
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/player_service.dart';
import 'package:music/ui/components/custom_window_button.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/menu/desktop_floating_menu.dart';
import 'package:music/ui/components/navigation_menu.dart';
import 'package:music/ui/components/playing/desktop_playing_bar.dart';
import 'package:music/ui/fragments/archive_fragment.dart';
import 'package:music/ui/fragments/artist_fragment.dart';
import 'package:music/ui/fragments/playlist_fragment.dart';
import 'package:music/ui/fragments/genre_fragment.dart';
import 'package:music/ui/fragments/songs_fragment.dart';

import '../../channels/app_method_channel.dart';
import '../fragments/album_fragment.dart';
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

   final List<Widget> fragments = [
    SongsFragment(),
    ArtistsFragment(),
    AlbumsFragment(),
     GenresFragment(),
     ArchiveFragment(),
     PlaylistFragment(),
     ArtistFragment(),
     AlbumFragment(),
     GenreFragment()
  ];

  @override
  void initState() {
    appState.setMainViewState = setState;
    super.initState();
  }
  
  String fragmentTitle() {
    switch(appState.fragmentIndex) {
      case FragmentIndex.songs:
        return "Songs";
      case FragmentIndex.artists:
        return "Artists";
      case FragmentIndex.albums:
        return "Albums";
      case FragmentIndex.genres:
        return "Genres";
      case FragmentIndex.archive:
        return "Archive";
      case FragmentIndex.playlist:
        return appStorage.playlists.get(appState.showingPlaylistId ?? "").title;
      case FragmentIndex.artist:
        return appStorage.artists.get(appState.showingArtistId ?? "").name.byContext(context);
      case FragmentIndex.album:
        return appStorage.albums.get(appState.showingAlbumId ?? "").title.byContext(context);
      default:
        return appStorage.genres[appState.showingGenre ?? ""]?.byContext(context) ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);

    var colors = CustomWindowButtonColors(
      iconMouseOver: Theme.of(context).textTheme.bodyMedium?.color,
      mouseOver: Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
      mouseDown: Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: Theme.of(context).textTheme.bodyMedium?.color,
    );

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
                      Expanded(child: MoveWindow(child: FragmentTitle(title: fragmentTitle()))),
                      MinimizeCustomWindowButton(
                        colors: colors
                      ),
                      appWindow.isMaximized
                          ? RestoreCustomWindowButton(
                        colors: colors,
                        onPressed: maximizeOrRestore,
                      )
                          : MaximizeCustomWindowButton(
                        colors: colors,
                        onPressed: maximizeOrRestore,
                      ),
                      CloseCustomWindowButton(
                        colors: CustomWindowButtonColors(
                          mouseOver: Color(0xFFD32F2F),
                          mouseDown: Color(0xFFB71C1C),
                          iconNormal: Color(0xFF805306),
                          iconMouseOver: Color(0xFFFFFFFF),
                          normal: Theme.of(context).scaffoldBackgroundColor
                        )
                      )
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
