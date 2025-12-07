import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> children = [
      _MenuHeader(text: AppLocalizations.of(context).get("@library")),
      _MenuItem(
          title: AppLocalizations.of(context).get("@songs"),
          icon: Icons.music_note,
          onPressed: () {
            ref.read(showingPlaylistIdProvider.notifier).set("!SONGS");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              saveWindowSize();
            }
          }),
      _MenuItem(
          title: AppLocalizations.of(context).get("@artists"),
          icon: Icons.people,
          onPressed: () {
            ref.read(showingPlaylistIdProvider.notifier).set("!ARTISTS");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              saveWindowSize();
            }
          }),
      _MenuItem(
          title: AppLocalizations.of(context).get("@albums"),
          icon: Icons.album,
          onPressed: () {
            ref.read(showingPlaylistIdProvider.notifier).set("!ALBUMS");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              saveWindowSize();
            }
            ref.read(playlistsProvider.notifier).preloadAlbumSongs();
          }),
      _MenuItem(
          title: AppLocalizations.of(context).get("@genres"),
          icon: Icons.piano,
          onPressed: () {
            ref.read(showingPlaylistIdProvider.notifier).set("!GENRES");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              saveWindowSize();
            }
          }),
      _MenuItem(
          title: AppLocalizations.of(context).get("@archive"),
          icon: Icons.archive,
          onPressed: () {
            ref.read(showingPlaylistIdProvider.notifier).set("!ARCHIVE");
            ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              saveWindowSize();
            }
          }),
      _MenuHeader(text: AppLocalizations.of(context).get("@playlists")),
    ];

    if (Platform.isMacOS && !appWindow.isMaximized) {
      children.insert(
          0,
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
              ],
            ),
          ));
    }

    final playlistsState = ref.watch(playlistsProvider);
    final idList = playlistsState.idList;
    final playlists = playlistsState.playlists;

    for(var id in idList) {
      final playlist = playlists.get(id);
      children.add(_MenuItem(
        title: playlist.title,
        icon: Icons.playlist_play,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set(playlist.id);
          ref.read(fragmentStateProvider.notifier).setState(titleMinimized: false, titleShowing: true);
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            saveWindowSize();
          }
        },
        onLongPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ConfirmationDialog(
                    title: AppLocalizations.of(context).get("@dialog_title_delete_playlist"),
                    onConfirmed: () {
                      playlist.deleted = DateTime.now();
                      playlist.save();
                      ref.read(playlistsProvider.notifier).movePlaylistToTrash(playlist.id);
                    });
              });
        },
      ));
    }
    return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: 200,
          decoration:
              BoxDecoration(color: Theme.of(context).cardColor, border: Border(right: BorderSide(color: Theme.of(context).shadowColor, width: 1))),
          child: ListView(
              children: children
          ),
        ));
  }
}

void saveWindowSize() {
  appCacheData.windowHeight = appWindow.size.height;
  appCacheData.windowWidth = appWindow.size.width;
  appCacheData.save();
}

class _MenuHeader extends StatelessWidget {
  final String text;

  const _MenuHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).disabledColor, fontSize: 12)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() onPressed;
  final void Function()? onLongPressed;

  const _MenuItem({required this.title, required this.icon, required this.onPressed, this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).highlightColor,
        size: 15,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: onPressed,
      onLongPress: onLongPressed,
    );
  }
}