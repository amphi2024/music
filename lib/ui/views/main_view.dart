import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/components/account/account_button.dart';
import 'package:music/ui/components/fragment_title.dart';
import 'package:music/ui/components/playing/playing_bar.dart';
import 'package:music/ui/fragments/home_fragment.dart';
import 'package:music/ui/fragments/library_fragment.dart';
import 'package:music/ui/fragments/search_fragment.dart';

import '../components/floating_menu.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  int fragmentIndex = 0;
  bool accountButtonExpanded = false;
  bool playingBarExpanded = false;
  bool menuShowing = false;

  @override
  Widget build(BuildContext context) {

    var fragments = [
      SongsFragment(),
      LibraryFragment(),
      SearchFragment()
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
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: fragments[fragmentIndex]),
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
                          child: FragmentTitle()
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
            PlayingBar(
              onTap: () {
                setState(() {
                  playingBarExpanded = true;
                });
              },
              expanded: playingBarExpanded,
            ),
          ],
        ),
      ),
    );
  }
}
