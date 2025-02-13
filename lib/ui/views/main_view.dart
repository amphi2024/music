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

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  int fragmentIndex = 0;
  bool accountButtonExpanded = false;

  @override
  Widget build(BuildContext context) {

    var fragments = [
      HomeFragment(),
      LibraryFragment(),
      SearchFragment()
    ];

    return PopScope(
      canPop: !accountButtonExpanded,
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          accountButtonExpanded = false;
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).padding.top,
                child: SizedBox(
                  height: 60,
                  child: Stack(
                    children: [
                      FragmentTitle(),
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
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: fragments[fragmentIndex]),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigationBar(
                  currentIndex: fragmentIndex,
                  onTap: (index) {
                    setState(() {
                      fragmentIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: "Home"
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.library_music),
                        label: "Library"
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: "Search"
                    ),
                  ]),
            ),
            PlayingBar(),
            AccountButton(
              expanded: accountButtonExpanded,
              onPressed: () {
                if(!accountButtonExpanded) {
                  setState(() {
                    accountButtonExpanded = true;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
