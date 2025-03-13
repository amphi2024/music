import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_theme.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {

    List<Widget> children = [
      _MenuItem(title: "Songs", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentIndex = 0;
        });
      }),
      _MenuItem(title: "Artists", icon: Icons.people, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentIndex = 1;
        });
      }),
      _MenuItem(title: "Albums", icon: Icons.album, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentIndex = 2;
        });
      }),
      _MenuItem(title: "Genres", icon: Icons.music_note, onPressed: () {
        appState.setMainViewState(() {
          appState.fragmentIndex = 3;
        });
      }),
    ];

    if(App.isDesktop() && !appWindow.isMaximized) {
      children.insert(0, SizedBox(
        height: 30,
        child: MoveWindow(),
      ));
    }

    return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).shadowColor,
                //color: Color.fromRGBO(240, 240, 240, 1),
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
