import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/providers.dart';
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
import '../../utils/fragment_title.dart';
import '../fragments/album_fragment.dart';
import '../fragments/albums_fragment.dart';
import '../fragments/artists_fragment.dart';
import '../fragments/genres_fragment.dart';

class WideMainPage extends ConsumerStatefulWidget {
  const WideMainPage({super.key});

  @override
  ConsumerState<WideMainPage> createState() => _WideMainViewState();
}

class _WideMainViewState extends ConsumerState<WideMainPage> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    final title = fragmentTitle(playlistId: playlistId, context: context, ref: ref);
    final floatingMenuShowing = ref.watch(floatingMenuShowingProvider);

    var colors = CustomWindowButtonColors(
      iconMouseOver: Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color,
      mouseOver: Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color,
      mouseDown: Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: Theme
          .of(context)
          .textTheme
          .bodyMedium
          ?.color,
    );

    List<Widget> children = [
      Expanded(child: FragmentTitle(title: title)),
    ];

    if (Platform.isWindows) {
      children = [
        Expanded(child: MoveWindow(child: FragmentTitle(title: title))),
        Visibility(
          visible: App.isDesktop(),
          child: MinimizeCustomWindowButton(colors: colors),
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
                normal: Theme
                    .of(context)
                    .scaffoldBackgroundColor))
      ];
    }
    if (Platform.isMacOS) {
      children = [
        Expanded(child: MoveWindow(child: FragmentTitle(title: title))),
      ];
    }

    return PopScope(
      canPop: !floatingMenuShowing,
      onPopInvokedWithResult: (didPop, result) {
        if (floatingMenuShowing) {
          ref.read(floatingMenuShowingProvider.notifier).set(false);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (floatingMenuShowing) {
            ref.read(floatingMenuShowingProvider.notifier).set(false);
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(toolbarHeight: 0 // This is needed to change the status bar text (icon) color on Android
          ),
          body: Stack(
            children: [
              AnimatedPositioned(
                  left: 200,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuint,
                  child: _Fragment(playlistId: playlistId)),
              Positioned(
                top: 0,
                left: 200,
                right: 0,
                child: SizedBox(
                  height: 55 + MediaQuery
                      .of(context)
                      .padding
                      .top,
                  child: Row(
                    children: children,
                  ),
                ),
              ),
              const NavigationMenu(),
              const DesktopPlayingBar(),
              const DesktopFloatingMenu()
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
      case "!SONGS":
    return SongsFragment();
    case "!ARTISTS":
    return ArtistsFragment();
    case "!ALBUMS":
    return AlbumsFragment();
    case "!GENRES":
    return GenresFragment();
    case "!ARCHIVE":
    return ArchiveFragment();
    case "!ARTIST":
    return ArtistFragment();
    case "!ALBUM":
      return
    AlbumFragment();
      case "!GENRE":
    return GenreFragment();
    default:
      return PlaylistFragment();
    }
  }
}