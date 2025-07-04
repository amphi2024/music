
import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_method_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/playing_bar.dart';
import 'package:music/ui/fragments/archive_fragment.dart';
import 'package:music/ui/fragments/genres_fragment.dart';
import 'package:music/ui/fragments/songs_fragment.dart';
import 'package:music/ui/fragments/artists_fragment.dart';
import 'package:music/ui/fragments/albums_fragment.dart';

import '../../models/fragment_index.dart';
import '../components/menu/floating_menu.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  
  bool menuShowing = false;
  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {
    appState.setMainViewState = (function) {
      setState(function);
    };
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => PlayingBar(),
      );
      overlay.insert(overlayEntry);
    });
  }

  final List<Widget> fragments = [
    SongsFragment(),
    ArtistsFragment(),
    AlbumsFragment(),
    GenresFragment(),
    ArchiveFragment()
  ];
  String fragmentTitle() {
    switch(appState.fragmentIndex) {
      case FragmentIndex.songs:
        return AppLocalizations.of(context).get("@songs");
      case FragmentIndex.artists:
        return AppLocalizations.of(context).get("@artists");
      case FragmentIndex.albums:
        return AppLocalizations.of(context).get("@albums");
      case FragmentIndex.genres:
        return AppLocalizations.of(context).get("@genres");
      case FragmentIndex.archive:
        return AppLocalizations.of(context).get("@archive");
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
    final themeData = Theme.of(context);
    if(appState.playingBarExpanded) {
      appMethodChannel.setNavigationBarColor(themeData.cardColor);
    }
    else {
      appMethodChannel.setNavigationBarColor(themeData.scaffoldBackgroundColor);
    }

    return PopScope(
      canPop: !appState.accountButtonExpanded && !appState.playingBarExpanded && !menuShowing && appState.selectedSongs == null,
      onPopInvokedWithResult: (didPop, result) {
        if(appState.playingBarExpanded) {
          appState.setState(() {
            appState.playingBarExpanded = false;
          });
        }
        if(appState.selectedSongs != null) {
          appState.setState(() {
            appState.selectedSongs = null;
          });
        }
        if(menuShowing) {
          setState(() {
            menuShowing = false;
          });
        }
        if(appState.accountButtonExpanded) {
          setState(() {
            appState.accountButtonExpanded = false;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          if(menuShowing) {
            setState(() {
              menuShowing = false;
            });
          }
        },
        onPanUpdate: (d) {
          if(d.delta.dx > 2) {
            setState(() {
              menuShowing = true;
            });
          }
          if(d.delta.dx < -2) {
            setState(() {
              menuShowing = false;
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
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: fragments[appState.fragmentIndex]),
              Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).padding.top,
                  child: GestureDetector(
                      onTap: () {
                        if(appState.fragmentTitleMinimized) {
                          appState.requestScrollToTop();
                        }
                        else {
                          setState(() {
                            menuShowing = !menuShowing;
                          });
                        }
                      },
                      child: FragmentTitle(
                        title: fragmentTitle(),
                      )
                  )),
              FloatingMenu(
                showing: menuShowing,
                requestHide: () {
                  setState(() {
                    menuShowing = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}