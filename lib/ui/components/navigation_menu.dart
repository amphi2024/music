
import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/fragment_index.dart';

import '../../models/app_storage.dart';
import '../../models/music/playlist.dart';

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
    //Color borderColor = Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2);
    List<Widget> children = [
      //_MenuDivider(title: "Library"),
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: SizedBox(
      //     height: 30,
      //     child: TextField(
      //       style: TextStyle(
      //         fontSize: 12.5
      //       ),
      //       decoration: InputDecoration(
      //         prefixIcon: Icon(
      //           Icons.search,
      //           size: 15,
      //           color: borderColor.withValues(alpha: 0.2),
      //         ),
      //         contentPadding: EdgeInsets.only(left: 5, right: 5),
      //         enabledBorder: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(5),
      //           borderSide: BorderSide(
      //               color: borderColor,
      //               style: BorderStyle.solid,
      //               width: 1),
      //         ),
      //         border: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(5),
      //           borderSide: BorderSide(
      //               color: borderColor,
      //               style: BorderStyle.solid,
      //               width: 1),
      //         ),
      //         focusedBorder: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(5),
      //           borderSide: BorderSide(
      //               color: Theme.of(context).colorScheme.primary,
      //               style: BorderStyle.solid,
      //               width: 2),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      _MenuHeader(text: "Library"),
      _MenuItem(title: "Songs", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.songs;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Artists", icon: Icons.people, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.artists;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Albums", icon: Icons.album, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.albums;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Genres", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.genres;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
      _MenuItem(title: "Archive", icon: Icons.archive, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.fragmentIndex = FragmentIndex.archive;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }),
       // Padding(
       //   padding: const EdgeInsets.only(left: 10, right: 10),
       //   child: Divider(
       //    color: Theme.of(context).dividerColor,
       //    thickness: 1,
       //         ),
       // )
      _MenuHeader(text: "Playlists"),
    ];

    if(Platform.isMacOS && !appWindow.isMaximized) {
      children.insert(0, SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            // IconButton(onPressed: () {
            //
            // }, icon: Icon(Icons.refresh))
          ],
        ),
      ));
    }

    //children.add(_MenuDivider(title: "Playlists"));

    List<Playlist> playlists = [];
    appStorage.playlists.forEach((id, playlist) {
      if(id != "" && !id.contains("!ALBUM") && !id.contains("!ARTIST")) {
        playlists.add(playlist);
      }
    });

    for(var playlist in playlists) {
      children.add(_MenuItem(title: playlist.title, icon: Icons.playlist_play, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentTitleShowing = true;
          appState.showingPlaylistId = playlist.id;
          appState.fragmentIndex = FragmentIndex.playlist;
        });
        if(App.isDesktop()) {
          saveWindowSize();
        }
      }));
    }

    return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            //color: AppTheme.lightGray,
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
  const _MenuItem({required this.title, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).highlightColor, size: 15,),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium,),
      onTap: onPressed,
    );
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.zero,
    //       side: BorderSide.none,
    //     ),
    //     backgroundColor: AppTheme.transparent,
    //     shadowColor: AppTheme.transparent
    //   ),
    //   onPressed: onPressed,
    //   child: Row(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Icon(icon),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Text(title),
    //       )
    //     ],
    //   ),
    // );
  }
}

// class _MenuDivider extends StatelessWidget {
//
//   final String title;
//   const _MenuDivider({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(child: Divider(
//             color: Theme.of(context).dividerColor,
//           )),
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0, right: 8),
//             child: Text(title),
//           ),
//           Expanded(child: Divider(
//             color: Theme.of(context).dividerColor,
//           )),
//         ],
//       ),
//     );
//   }
// }