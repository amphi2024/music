import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/components/account/account_button.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/playing_bar.dart';
import 'package:music/ui/fragments/genres_fragment.dart';
import 'package:music/ui/fragments/songs_fragment.dart';
import 'package:music/ui/fragments/artists_fragment.dart';
import 'package:music/ui/fragments/albums_fragment.dart';

import '../components/menu/floating_menu.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  bool accountButtonExpanded = false;
  bool playingBarExpanded = false;
  bool menuShowing = false;
  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {
    appState.setMainViewState = (function) {
      setState(function);
    };
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("234j3243284ldsjsdlfslkfjsdflsjf23940392493024");
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => PlayingBar(),
      );
      overlay.insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {

    var fragments = [
      SongsFragment(),
      ArtistsFragment(),
      AlbumsFragment(),
      GenresFragment()
    ];
    var titles = [
      "Songs3",
      "Artists",
      "Albums",
      "Genres"
    ];

    return PopScope(
      canPop: !accountButtonExpanded && !playingBarExpanded && !menuShowing,
      onPopInvokedWithResult: (didPop, result) {
        if(playingBarExpanded) {
          setState(() {
            playingBarExpanded = false;
          });
        }
        if(menuShowing) {
          setState(() {
            menuShowing = false;
          });
        }
        if(accountButtonExpanded) {
          setState(() {
            accountButtonExpanded = false;
          });
        }
      },
      child: GestureDetector(
        onPanUpdate: (d) {
          if(d.delta.dx > 2) {
            setState(() {
              menuShowing = true;
            });
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: fragments[appState.fragmentIndex]),
              Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).padding.top,
                  child: SizedBox(
                    height: 60,
                    child: Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                menuShowing = true;
                              });
                            },
                            child: FragmentTitle(
                              title: titles[appState.fragmentIndex],
                            )
                        ),
                        Positioned(
                          right: 60,
                          top: 0,
                          child: Row(
                            children: [
                              IconButton(onPressed: () async {
                                var result = await FilePicker.platform.pickFiles(
                                    type: FileType.audio
                                );
                                if(result != null) {
                                  for(var file in result.files) {
                                    var filePath = file.path;
                                    if(filePath != null && File(filePath).existsSync()) {
                                      appStorage.createMusicAndAll(filePath);
                                    }
                                  }
                                }
                              }, icon: Icon(Icons.add))
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              FloatingMenu(
                showing: menuShowing,
                requestHide: () {
                  setState(() {
                    menuShowing = false;
                  });
                },
              ),
              AccountButton(
                expanded: accountButtonExpanded,
                onPressed: () {
                  if(!accountButtonExpanded) {
                    setState(() {
                      accountButtonExpanded = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
