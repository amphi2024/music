
import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/account/account_button.dart';
import 'package:music/ui/components/add_item_button.dart';
import 'package:music/ui/components/menu/floating_menu_button.dart';
import 'package:music/ui/views/playlist_view.dart';
import 'package:music/ui/views/settings_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/fragment_index.dart';

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
    final double height = 350;
    final screenHeight = MediaQuery.of(context).size.height;
    double verticalPadding = (screenHeight - height) / 2;

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
          height: height,
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
                  AddItemButton(),
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
            label: AppLocalizations.of(context).get("@songs"),
            onPressed: () {
              appState.setMainViewState(() {
                appState.fragmentTitleMinimized = false;
                appState.fragmentIndex = FragmentIndex.songs;
              });
            }),
        FloatingMenuButton(
            icon: Icons.people,
            label: AppLocalizations.of(context).get("@artists"),
            onPressed: () {
              appState.setMainViewState(() {
                appState.fragmentTitleMinimized = false;
                appState.fragmentIndex = FragmentIndex.artists;
              });
            }),
        FloatingMenuButton(
            icon: Icons.album,
            label: AppLocalizations.of(context).get("@albums"),
            onPressed: () {
              appState.setMainViewState(() {
                appState.fragmentTitleMinimized = false;
                appState.fragmentIndex = FragmentIndex.albums;
              });
            }),
        FloatingMenuButton(
            icon: Icons.piano,
            label: AppLocalizations.of(context).get("@genres"),
            onPressed: () {
              appState.setMainViewState(() {
                appState.fragmentTitleMinimized = false;
                appState.fragmentIndex = FragmentIndex.genres;
              });
            }),
        FloatingMenuButton(
            icon: Icons.archive,
            label: AppLocalizations.of(context).get("@archive"),
            onPressed: () {
              appState.setMainViewState(() {
                appState.fragmentTitleMinimized = false;
                appState.fragmentIndex = FragmentIndex.archive;
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

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: appStorage.playlistIdList.length,
      itemBuilder: (context, index) {
        final id = appStorage.playlistIdList[index];
        var playlist = appStorage.playlists.get(id);
        return  FloatingMenuButton(
            icon: Icons.playlist_play,
            label: playlist.title,
            onLongPressed: () {
              showDialog(context: context, builder: (context) {
                return ConfirmationDialog(title: AppLocalizations.of(context).get("@dialog_title_delete_playlist"), onConfirmed: () {
                  appState.setState(() {
                    playlist.delete();
                    appStorage.playlists.remove(playlist.id);
                    appStorage.playlistIdList.remove(playlist.id);
                  });
                });
              });
            },
            onPressed: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => PlaylistView(playlist: playlist)));
            });
      },
    );
  }
}
