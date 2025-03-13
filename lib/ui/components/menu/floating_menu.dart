import 'dart:io';

import 'package:amphi/widgets/profile_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/ui/components/account/account_button.dart';
import 'package:music/ui/components/menu/floating_menu_button.dart';
import 'package:music/ui/dialogs/edit_playlist_dialog.dart';
import 'package:music/ui/views/settings_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FloatingMenu extends StatefulWidget {
  final bool showing;
  final void Function() requestHide;

  const FloatingMenu(
      {super.key, required this.showing, required this.requestHide});

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu> {

  var pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height > 300 ? 150 : 20;

    return AnimatedPositioned(
      left: widget.showing ? 15 : -300,
      bottom: verticalPadding,
      curve: Curves.easeOutQuint,
      duration: const Duration(milliseconds: 750),
      child: GestureDetector(
        onPanUpdate: (d) {
          if (d.delta.dx < -3) {
            widget.requestHide();
          }
        },
        child: Container(
          width: 250,
          height: 300,
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
                child: PageView(
                  controller: pageController,
                  children: [
                    _Buttons(),
                    _Playlists()
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: pageController, count: 2,
                effect: WormEffect(
                  dotColor: Theme.of(context).dividerColor,
                  activeDotColor: Theme.of(context).highlightColor,
                  dotHeight: 15,
                  dotWidth: 15,
                ),
                onDotClicked: (index) {
                  pageController.animateToPage(index, duration: Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AccountButton(),
                  PopupMenuButton(
                    icon: Icon(Icons.add_circle_outline),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text("Song"), onTap: () async {
                         appStorage.selectMusicFilesAndSave();
                        }),
                        PopupMenuItem(child: Text("Playlist"), onTap: () {
                          showDialog(context: context, builder: (context) {
                            return EditPlaylistDialog(onSave: (playlist) {
                              appState.setMainViewState(() {
                                appStorage.playlists[playlist.id] = playlist;
                              });
                            });
                          });
                        }),
                      ];
                    },
                  ),
                  IconButton(icon: Icon(Icons.settings), onPressed: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) {
                      return SettingsView();
                    },));
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return ListView(
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
      ],
    );
  }
}

class _Playlists extends StatelessWidget {
  const _Playlists();

  @override
  Widget build(BuildContext context) {

    List<Playlist> playlists = [];
    appStorage.playlists.forEach((id, playlist) {
      if(id != "") {
        playlists.add(playlist);
      }
    });

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        var playlist = playlists[index];
        return  FloatingMenuButton(
            icon: Icons.playlist_play,
            label: playlist.title,
            onPressed: () {

            });
      },
    );
  }
}
