import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/playing_bar.dart';
import 'package:music/ui/fragments/archive_fragment.dart';
import 'package:music/ui/fragments/genres_fragment.dart';
import 'package:music/ui/fragments/songs_fragment.dart';
import 'package:music/ui/fragments/artists_fragment.dart';
import 'package:music/ui/fragments/albums_fragment.dart';
import 'package:music/ui/fragments/trash_fragment.dart';

import '../../../channels/app_method_channel.dart';
import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';
import '../../../utils/fragment_title.dart';
import '../../../utils/toast.dart';
import '../../../utils/update_check.dart';
import '../../components/menu/floating_menu.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainPage> {

  bool menuShowing = false;
  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
    checkForServerUpdate(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => PlayingBar(),
      );
      overlay.insert(overlayEntry);

      if (appSettings.useOwnServer && appWebChannel.uploadBlocked) {
        showToast(context, AppLocalizations.of(context).get("server_version_old_message"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final playingBarExpanded = ref.watch(playingBarExpandedProvider);
    final selectedSongs = ref.watch(selectedItemsProvider);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    if (playingBarExpanded) {
      appMethodChannel.setNavigationBarColor(themeData.cardColor);
    }
    else {
      appMethodChannel.setNavigationBarColor(themeData.scaffoldBackgroundColor);
    }

    return PopScope(
      canPop: !playingBarExpanded && !menuShowing && selectedSongs == null,
      onPopInvokedWithResult: (didPop, result) {
        if (playingBarExpanded) {
          ref.read(playingBarExpandedProvider.notifier).set(false);
        }
        if (selectedSongs != null) {
          ref.read(selectedItemsProvider.notifier).endSelection();
        }
        if (menuShowing) {
          setState(() {
            menuShowing = false;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          if (menuShowing) {
            setState(() {
              menuShowing = false;
            });
          }
        },
        onPanUpdate: (d) {
          if (d.delta.dx > 2) {
            setState(() {
              menuShowing = true;
            });
          }
          if (d.delta.dx < -2) {
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
                  child: _Fragment(playlistId: playlistId)),
              Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery
                      .of(context)
                      .padding
                      .top,
                  child: GestureDetector(
                      onTap: () {
                          setState(() {
                            menuShowing = !menuShowing;
                          });
                      },
                      child: FragmentTitle(
                        title: fragmentTitle(playlistId: playlistId, context: context, ref: ref),
                      )
                  )),
              FloatingMenu(
                showing: menuShowing,
                requestHide: () {
                  setState(() {
                    menuShowing = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Fragment extends StatelessWidget {

  final String playlistId;
  const _Fragment({required this.playlistId});

  @override
  Widget build(BuildContext context) {
    switch(playlistId.split(",").first) {
      case "!ARTISTS":
        return ArtistsFragment();
      case "!ALBUMS":
        return AlbumsFragment();
      case "!GENRES":
        return GenresFragment();
      case "!ARCHIVE":
        return ArchiveFragment();
      case "!TRASH":
        return TrashFragment();
      default:
        return SongsFragment();
    }
  }
}