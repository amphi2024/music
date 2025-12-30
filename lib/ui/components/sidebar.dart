import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:amphi/widgets/move_window_button_or_spacer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/move_to_trash.dart';

import '../../channels/app_method_channel.dart';
import '../../channels/app_web_channel.dart';
import '../../models/app_storage.dart';
import '../../utils/account_utils.dart';
import '../dialogs/settings_dialog.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarWidth = ref.watch(sideBarWidthProvider);

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(color: Theme.of(context).navigationBarTheme.backgroundColor),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                  child: SizedBox(
                    height: 55,
                    child: Row(
                      children: [const Expanded(child: MoveWindowOrSpacer()), AccountButton(
                        appCacheData: appCacheData,
                        onLoggedIn: ({required id, required token, required username}) {
                          onLoggedIn(id: id, token: token, username: username, context: context, ref: ref);
                        },
                        iconSize: 25,
                        profileIconSize: 20,
                        wideScreenIconSize: 25,
                        wideScreenProfileIconSize: 20,
                        appWebChannel: appWebChannel,
                        appStorage: appStorage,
                        onUserRemoved: () {
                          onSelectedUserChanged(ref);
                        },
                        onUserAdded: () {
                          onSelectedUserChanged(ref);
                        },
                        onUsernameChanged: () {
                          onUsernameChanged(ref);
                        },
                        onSelectedUserChanged: (user) {
                          onSelectedUserChanged(ref);
                        },
                        setAndroidNavigationBarColor: () {
                          appMethodChannel.setNavigationBarColor(Theme.of(context).cardColor);
                        },
                      )],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(padding: EdgeInsets.only(left: 5), children: _menuItems(ref: ref, context: context)),
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
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: () {
                ref.read(sideBarWidthProvider.notifier).set(200);
                appCacheData.sidebarWidth = 200;
                appCacheData.save();
              },
              onHorizontalDragUpdate: (d) {
                ref.read(sideBarWidthProvider.notifier).set(sidebarWidth + d.delta.dx);
              },
              onHorizontalDragEnd: (d) {
                appCacheData.sidebarWidth = sidebarWidth;
                appCacheData.save();
              },
              child: SizedBox(
                width: 5,
                child: VerticalDivider(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _menuItems({required WidgetRef ref, required BuildContext context}) {
  final showingPlaylistId = ref.watch(showingPlaylistIdProvider);
  List<Widget> children = [
    _MenuHeader(text: AppLocalizations.of(context).get("@library")),
    DragTarget<List<String>>(
      onAcceptWithDetails: (details) {
        if(showingPlaylistId != "!ARCHIVE") {
          return;
        }
        final selectedSongs = details.data;
        final songs = ref.read(songsProvider);
        for(var id in selectedSongs) {
          final song = songs.get(id);
          song.archived = false;
          song.save();
        }
        ref.read(playlistsProvider.notifier).restoreFromArchive(selectedSongs);
      },
      builder: (context, candidateData, rejectedData) {
        return _MenuItem(
            focused: showingPlaylistId == "!SONGS",
            title: AppLocalizations.of(context).get("@songs"),
            icon: Icons.music_note,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!SONGS");
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                saveWindowSize();
              }
            });
      },
    ),
    _MenuItem(
        focused: showingPlaylistId == "!ARTISTS",
        title: AppLocalizations.of(context).get("@artists"),
        icon: Icons.people,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!ARTISTS");
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            saveWindowSize();
          }
        }),
    _MenuItem(
        focused: showingPlaylistId == "!ALBUMS",
        title: AppLocalizations.of(context).get("@albums"),
        icon: Icons.album,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!ALBUMS");
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            saveWindowSize();
          }
        }),
    _MenuItem(
        focused: showingPlaylistId == "!GENRES",
        title: AppLocalizations.of(context).get("@genres"),
        icon: Icons.piano,
        onPressed: () {
          ref.read(showingPlaylistIdProvider.notifier).set("!GENRES");
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            saveWindowSize();
          }
        }),
    DragTarget<List<String>>(
      onAcceptWithDetails: (details) {
        if(showingPlaylistId == "!ARCHIVE") {
          return;
        }
        final selectedSongs = details.data;
        final songs = ref.read(songsProvider);
        for(var id in selectedSongs) {
          final song = songs.get(id);
          song.archived = true;
          song.save();
        }
        ref.read(playlistsProvider.notifier).moveToArchive(selectedSongs);
      },
      builder: (context, candidateData, rejectedData) {
        return _MenuItem(
            focused: showingPlaylistId == "!ARCHIVE",
            title: AppLocalizations.of(context).get("@archive"),
            icon: Icons.archive,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!ARCHIVE");
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                saveWindowSize();
              }
            });
      },
    ),
    DragTarget<List<String>>(
      onAcceptWithDetails: (details) {
        if(showingPlaylistId == "!SONGS" || !showingPlaylistId.startsWith("!")) {
          moveSelectedSongsToTrash(selectedItems: ref.read(selectedItemsProvider) ?? [], showingPlaylistId: showingPlaylistId, ref: ref);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return _MenuItem(
            focused: showingPlaylistId == "!TRASH",
            title: AppLocalizations.of(context).get("trash"),
            icon: Icons.delete,
            onPressed: () {
              ref.read(showingPlaylistIdProvider.notifier).set("!TRASH");
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                saveWindowSize();
              }
            });
      },
    ),
    _MenuHeader(text: AppLocalizations.of(context).get("@playlists")),
  ];

  final playlistsState = ref.watch(playlistsProvider);
  final idList = playlistsState.idList;
  final playlists = playlistsState.playlists;

  for (var id in idList) {
    final playlist = playlists.get(id);
    children.add(DragTarget<List<String>>(onAcceptWithDetails: (details) {
      final selectedSongs = details.data;
      final items = selectedSongs.toSet().difference(playlist.songs.toSet());
      playlist.songs.addAll(items);
      playlist.songs.sortSongsWidgerRef(playlist.id, ref);
      playlist.save();
      ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
    }, builder: (context, candidateData, rejectedData) {
      return _MenuItem(
        focused: showingPlaylistId == playlist.id,
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
      );
    }));
  }

  return children;
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
      padding: const EdgeInsets.only(left: 8.0, top: 5, bottom: 5),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).disabledColor, fontSize: 12)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool focused;
  final void Function() onPressed;
  final void Function()? onLongPressed;

  const _MenuItem({required this.title, required this.icon, required this.onPressed, this.onLongPressed, required this.focused});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: focused ? Theme.of(context).dividerColor.withAlpha(50) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 15, top: 10, bottom: 10),
              child: Icon(icon, size: 15, color: Theme.of(context).highlightColor),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
