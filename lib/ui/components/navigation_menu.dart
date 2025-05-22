
import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/fragment_index.dart';

import '../../models/app_storage.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {

  void saveWindowSize() {
    appCacheData.windowHeight = appWindow.size.height;
    appCacheData.windowWidth = appWindow.size.width;
    appCacheData.save();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      _MenuHeader(text: "Library"),
      _MenuItem(title: "Songs", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.songs;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Artists", icon: Icons.people, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.artists;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Albums", icon: Icons.album, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.albums;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Genres", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.genres;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Archive", icon: Icons.archive, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.archive;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuHeader(text: "Playlists"),
    ];

    if(Platform.isMacOS && !appWindow.isMaximized) {
      children.insert(0, SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
          ],
        ),
      ));
    }

    for(var playlistId in appStorage.playlistIdList) {
      var playlist = appStorage.playlists.get(playlistId);
      children.add(_MenuItem(title: playlist.title, icon: Icons.playlist_play, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
          appState.fragmentTitleShowing = true;
          appState.showingPlaylistId = playlist.id;
          appState.fragmentIndex = FragmentIndex.playlist;
        });
        appState.setFragmentState(() {

        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      },
      onLongPressed: () {
        showDialog(context: context, builder: (context) {
          return ConfirmationDialog(title: "", onConfirmed: () {
            appState.setState(() {
              playlist.delete();
              appStorage.playlists.remove(playlist.id);
              appStorage.playlistIdList.remove(playlist.id);
            });
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
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).shadowColor,
                width: 1
              )
            )
          ),
          child: ListView(
            children: children
          ),
        )
    );
  }
}

class _MenuHeader extends StatelessWidget {
  
  final String text;
  const _MenuHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(text, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).disabledColor,
        fontSize: 12
      )),
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
      leading: Icon(icon, color: Theme.of(context).highlightColor, size: 15,),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
      onTap: onPressed,
      onLongPress: onLongPressed,
    );
  }
}