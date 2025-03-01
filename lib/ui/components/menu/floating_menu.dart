import 'dart:io';

import 'package:amphi/widgets/profile_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/menu/floating_menu_button.dart';

class FloatingMenu extends StatelessWidget {
  final bool showing;
  final void Function() requestHide;

  const FloatingMenu(
      {super.key, required this.showing, required this.requestHide});

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height > 300 ? 150 : 20;
    return AnimatedPositioned(
      left: showing ? 15 : -300,
      top: verticalPadding,
      bottom: verticalPadding,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (d.delta.dx < -3) {
            requestHide();
          }
        },
        child: Container(
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    FloatingMenuButton(
                        icon: Icons.music_note,
                        label: "Songs",
                        onPressed: () {
                          appState.setMainViewState(() {
                            appState.fragmentIndex = 0;
                          });
                        }),
                    FloatingMenuButton(
                        icon: Icons.people,
                        label: "Artists",
                        onPressed: () {
                          appState.setMainViewState(() {
                            appState.fragmentIndex = 1;
                          });
                        }),
                    FloatingMenuButton(
                        icon: Icons.album,
                        label: "Albums",
                        onPressed: () {
                          appState.setMainViewState(() {
                            appState.fragmentIndex = 2;
                          });
                        }),
                    FloatingMenuButton(
                        icon: Icons.music_note,
                        label: "Genres",
                        onPressed: () {
                          appState.setMainViewState(() {
                            appState.fragmentIndex = 3;
                          });
                        }),
                    FloatingMenuButton(
                        icon: Icons.playlist_play,
                        label: "Playlists",
                        onPressed: () {
                          appState.setMainViewState(() {
                            appState.fragmentIndex = 3;
                          });
                        }),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      icon: ProfileImage(
                          user: appStorage.selectedUser,
                          token: appStorage.selectedUser.token,
                          size: Theme.of(context).iconTheme.size ?? 15),
                      onPressed: () {}),
                  PopupMenuButton(
                    icon: Icon(Icons.add_circle_outline),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text("Music"), onTap: () async {
                          var result = await FilePicker.platform
                              .pickFiles(type: FileType.audio);
                          if (result != null) {
                            for (var file in result.files) {
                              var filePath = file.path;
                              if (filePath != null &&
                                  File(filePath).existsSync()) {
                                appStorage.createMusicAndAll(filePath);
                              }
                            }
                          }
                        }),
                        PopupMenuItem(child: Text("Playlist"), onTap: () {

                        }),
                      ];
                    },
                  ),
                  IconButton(icon: Icon(Icons.settings), onPressed: () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
