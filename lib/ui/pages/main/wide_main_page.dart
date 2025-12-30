import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/sidebar.dart';
import 'package:music/ui/fragments/archive_fragment.dart';
import 'package:music/ui/fragments/artist_fragment.dart';
import 'package:music/ui/fragments/playlist_fragment.dart';
import 'package:music/ui/fragments/genre_fragment.dart';
import 'package:music/ui/fragments/songs_fragment.dart';
import 'package:music/ui/fragments/trash_fragment.dart';
import 'package:music/ui/pages/main/now_playing_panel.dart';
import 'package:music/ui/pages/main/wide_main_page_fragment_title.dart';

import '../../../channels/app_method_channel.dart';
import '../../../models/app_cache.dart';
import '../../fragments/album_fragment.dart';
import '../../fragments/albums_fragment.dart';
import '../../fragments/artists_fragment.dart';
import '../../fragments/genres_fragment.dart';

class WideMainPage extends ConsumerStatefulWidget {
  const WideMainPage({super.key});

  @override
  ConsumerState<WideMainPage> createState() => _WideMainViewState();
}

class _WideMainViewState extends ConsumerState<WideMainPage> {
  final focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    final nowPlayingPanelWidth = ref.watch(nowPlayingPanelWidthProvider);
    final themeData = Theme.of(context);
    final selectedSongs = ref.watch(selectedItemsProvider);

    return PopScope(
      canPop: selectedSongs == null,
      onPopInvokedWithResult: (didPop, result) {
        if(selectedSongs != null) {
          ref.read(selectedItemsProvider.notifier).endSelection();
        }
      },
      child: Scaffold(
        backgroundColor: themeData.cardColor,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(toolbarHeight: 0 // This is needed to change the status bar text (icon) color on Android
            ),
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
                child: MouseRegion(
              onHover: (event) {
                focusNode.requestFocus();
              },
              onExit: (event) {
                focusNode.unfocus();
              },
              child: Column(
                children: [
                  const WideMainPageFragmentTitle(),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: KeyboardListener(
                        focusNode: focusNode,
                        includeSemantics: false,
                        onKeyEvent: (event) {
                          if (event is KeyUpEvent) {
                            ref.read(selectedItemsProvider.notifier).ctrlPressed = false;
                            ref.read(selectedItemsProvider.notifier).shiftPressed = false;
                            return;
                          }
                          if (event.physicalKey == PhysicalKeyboardKey.metaLeft || event.physicalKey == PhysicalKeyboardKey.controlLeft || event.physicalKey == PhysicalKeyboardKey.controlRight) {
                            ref.read(selectedItemsProvider.notifier).ctrlPressed = true;
                            ref.read(selectedItemsProvider.notifier).shiftPressed = false;
                            if (ref.watch(selectedItemsProvider) == null) {
                              ref.read(selectedItemsProvider.notifier).startSelection();
                            }
                          }

                          if (event.physicalKey == PhysicalKeyboardKey.shiftLeft || event.physicalKey == PhysicalKeyboardKey.shiftRight) {
                            ref.read(selectedItemsProvider.notifier).ctrlPressed = false;
                            ref.read(selectedItemsProvider.notifier).shiftPressed = true;
                            if (ref.watch(selectedItemsProvider) == null) {
                              ref.read(selectedItemsProvider.notifier).startSelection();
                            }
                          }

                          if (ref.read(selectedItemsProvider.notifier).ctrlPressed && event.physicalKey == PhysicalKeyboardKey.keyA) {
                            ref.read(selectedItemsProvider.notifier).addAll(showingPlaylist(ref).songs);
                          }
                        },
                        child: _Fragment(playlistId: playlistId)),
                  )),
                ],
              ),
            )),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () {
                  ref.read(nowPlayingPanelWidthProvider.notifier).set(300);
                  appCacheData.nowPlayingPanelWidth = 300;
                  appCacheData.save();
                },
                onHorizontalDragUpdate: (d) {
                  ref.read(nowPlayingPanelWidthProvider.notifier).set(nowPlayingPanelWidth - d.delta.dx);
                },
                onHorizontalDragEnd: (d) {
                  appCacheData.nowPlayingPanelWidth = nowPlayingPanelWidth;
                  appCacheData.save();
                },
                child: VerticalDivider(color: Theme.of(context).dividerColor, width: 10),
              ),
            ),
            const NowPlayingPanel()
          ],
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
    switch (playlistId.split(",").first) {
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
        return AlbumFragment();
      case "!GENRE":
        return GenreFragment();
      case "!TRASH":
        return TrashFragment();
      default:
        return PlaylistFragment();
    }
  }
}