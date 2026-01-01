import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/tablet_playing_bar.dart';

import '../../../channels/app_method_channel.dart';
import '../../../channels/app_web_channel.dart';
import '../../../models/app_settings.dart';
import '../../../providers/fragment_provider.dart';
import '../../../providers/playlists_provider.dart';
import '../../../providers/providers.dart';
import '../../../utils/fragment_title.dart';
import '../../../utils/toast.dart';
import '../../dialogs/settings_dialog.dart';
import '../../fragments/album_fragment.dart';
import '../../fragments/albums_fragment.dart';
import '../../fragments/archive_fragment.dart';
import '../../fragments/artist_fragment.dart';
import '../../fragments/artists_fragment.dart';
import '../../fragments/genre_fragment.dart';
import '../../fragments/genres_fragment.dart';
import '../../fragments/playlist_fragment.dart';
import '../../fragments/songs_fragment.dart';
import '../../fragments/trash_fragment.dart';

class TabletMainPage extends ConsumerStatefulWidget {
  const TabletMainPage({super.key});

  @override
  TabletMainPageState createState() => TabletMainPageState();
}

class TabletMainPageState extends ConsumerState<TabletMainPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (appSettings.useOwnServer && appWebChannel.uploadBlocked) {
        showToast(context, AppLocalizations.of(context).get("server_version_old_message"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    final selectedSongs = ref.watch(selectedItemsProvider);
    final mediaQuery = MediaQuery.of(context);

    return PopScope(
      canPop: selectedSongs == null,
      onPopInvokedWithResult: (didPop, result) {
        if(selectedSongs != null) {
          ref.read(selectedItemsProvider.notifier).endSelection();
        }
      },
      child: Scaffold(
        appBar: Platform.isAndroid ? AppBar(
            toolbarHeight: 0 // This is needed to change the status bar text (icon) color on Android
        ) : null,
        body: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 250,
                  color: Theme
                      .of(context)
                      .navigationBarTheme
                      .backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top, bottom: Platform.isIOS ? 0 : MediaQuery.paddingOf(context).bottom),
                    child: Column(
                      children: [
                        Row(
                          children: [

                          ],
                        ),
                        Expanded(
                          child: ListView(
                              padding: EdgeInsets.only(left: 5),
                              children: _menuItems(ref: ref, context: context)),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SettingsDialog();
                                      });
                                },
                                icon: Icon(Icons.settings, size: 15))
                          ],
                        )
                      ],
                    ),
                  ),
                )),
            Positioned(
                left: 250,
                top: 0,
                bottom: 0,
                right: 0,
                child: _Fragment(playlistId: playlistId)),
            Positioned(
                left: 250,
                top: 0,
                right: 0,
                child: FragmentTitle(title: fragmentTitle(playlistId: playlistId, context: context, ref: ref))),
            Positioned(
              left: 250 + 40,
                // Set padding to 15 in cases of iOS gestures or older iOS/Android versions
                bottom: mediaQuery.padding.bottom < 40 ? 40 : mediaQuery.padding.bottom,
                right: 40,
                child: TabletPlayingBar())
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final String text;

  const _MenuHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 5, bottom: 5),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).disabledColor,
              fontSize: 15)),
    );
  }
}

List<Widget> _menuItems(
    {required WidgetRef ref, required BuildContext context}) {
  final showingPlaylistId = ref.watch(showingPlaylistIdProvider);
  List<Widget> children = [
    _MenuHeader(text: AppLocalizations.of(context).get("@library")),
    _MenuItem(
            focused: showingPlaylistId == "!SONGS",
            title: AppLocalizations.of(context).get("@songs"),
            icon: Icons.music_note,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!SONGS");
            }),
    _MenuItem(
        focused: showingPlaylistId == "!ARTISTS",
        title: AppLocalizations.of(context).get("@artists"),
        icon: Icons.people,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!ARTISTS");
        }),
    _MenuItem(
        focused: showingPlaylistId == "!ALBUMS",
        title: AppLocalizations.of(context).get("@albums"),
        icon: Icons.album,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!ALBUMS");
        }),
    _MenuItem(
        focused: showingPlaylistId == "!GENRES",
        title: AppLocalizations.of(context).get("@genres"),
        icon: Icons.piano,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!GENRES");
        }),
    _MenuItem(
            focused: showingPlaylistId == "!ARCHIVE",
            title: AppLocalizations.of(context).get("@archive"),
            icon: Icons.archive,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!ARCHIVE");
            }),
    _MenuItem(
            focused: showingPlaylistId == "!TRASH",
            title: AppLocalizations.of(context).get("trash"),
            icon: Icons.delete,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!TRASH");
            }),
    _MenuHeader(text: AppLocalizations.of(context).get("@playlists")),
  ];

  final playlistsState = ref.watch(playlistsProvider);
  final idList = playlistsState.idList;
  final playlists = playlistsState.playlists;

  for (var id in idList) {
    final playlist = playlists.get(id);
    children.add(_MenuItem(
        focused: showingPlaylistId == playlist.id,
        title: playlist.title,
        icon: Icons.playlist_play,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set(playlist.id);
          ref
              .read(fragmentStateProvider.notifier)
              .setState(titleMinimized: false, titleShowing: true);
        },
        onLongPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ConfirmationDialog(
                    title: AppLocalizations.of(context)
                        .get("@dialog_title_delete_playlist"),
                    onConfirmed: () {
                      playlist.deleted = DateTime.now();
                      playlist.save();
                      ref
                          .read(playlistsProvider.notifier)
                          .movePlaylistToTrash(playlist.id);
                    });
              });
        },
    ));
  }

  return children;
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool focused;
  final void Function() onPressed;
  final void Function()? onLongPressed;

  const _MenuItem(
      {required this.title,
        required this.icon,
        required this.onPressed,
        this.onLongPressed,
        required this.focused});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: focused
          ? Theme.of(context).dividerColor.withAlpha(50)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 10, left: 15, top: 10, bottom: 10),
              child:
              Icon(icon, size: 15, color: Theme.of(context).highlightColor),
            ),
            Text(title)
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
    switch (playlistId
        .split(",")
        .first) {
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