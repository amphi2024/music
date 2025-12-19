import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/add_item_button.dart';
import 'package:music/ui/components/menu/floating_menu_button.dart';
import 'package:music/ui/pages/playlist_page.dart';
import 'package:music/ui/pages/settings_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/account_utils.dart';

class FloatingMenu extends ConsumerStatefulWidget {
  final bool showing;
  final void Function() requestHide;

  const FloatingMenu({super.key, required this.showing, required this.requestHide});

  @override
  ConsumerState<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends ConsumerState<FloatingMenu> {
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).cardColor, boxShadow: [
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
                    ListView(
                      padding: EdgeInsets.zero,
                      children: _menuButtons(ref: ref, context: context),
                    ),
                    _Playlists()
                  ],
                ),
              ),
              SmoothPageIndicator(
                controller: pageController,
                count: 2,
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
                  AccountButton(
                    appCacheData: appCacheData,
                    onLoggedIn: ({required id, required token, required username}) {
                      onLoggedIn(id: id, token: token, username: username, context: context, ref: ref);
                    },
                    iconSize: 20,
                    profileIconSize: 15,
                    wideScreenIconSize: 15,
                    wideScreenProfileIconSize: 15,
                    appWebChannel: appWebChannel,
                    appStorage: appStorage,
                    onUserRemoved: () {},
                    onUserAdded: () {},
                    onUsernameChanged: () {},
                    onSelectedUserChanged: (user) {},
                    setAndroidNavigationBarColor: () {},
                  ),
                  AddItemButton(),
                  IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(context, CupertinoPageRoute(
                          builder: (context) {
                            return SettingsPage();
                          },
                        ));
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

List<Widget> _menuButtons({required WidgetRef ref, required BuildContext context}) {
  return [
    FloatingMenuButton(
        icon: Icons.music_note,
        label: AppLocalizations.of(context).get("@songs"),
        onPressed: () {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
          ref.read(showingPlaylistIdProvider.notifier).set("!SONGS");
        }),
    FloatingMenuButton(
        icon: Icons.people,
        label: AppLocalizations.of(context).get("@artists"),
        onPressed: () {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
          ref.read(showingPlaylistIdProvider.notifier).set("!ARTISTS");
        }),
    FloatingMenuButton(
        icon: Icons.album,
        label: AppLocalizations.of(context).get("@albums"),
        onPressed: () {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
          ref.read(showingPlaylistIdProvider.notifier).set("!ALBUMS");
        }),
    FloatingMenuButton(
        icon: Icons.piano,
        label: AppLocalizations.of(context).get("@genres"),
        onPressed: () {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
          ref.read(showingPlaylistIdProvider.notifier).set("!GENRES");
        }),
    FloatingMenuButton(
        icon: Icons.archive,
        label: AppLocalizations.of(context).get("@archive"),
        onPressed: () {
          ref.read(fragmentStateProvider.notifier).setTitleMinimized(false);
          ref.read(showingPlaylistIdProvider.notifier).set("!ARCHIVE");
        }),
  ];
}

class _Playlists extends ConsumerWidget {
  const _Playlists();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsState = ref.watch(playlistsProvider);
    final idList = playlistsState.idList;
    final playlists = playlistsState.playlists;
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: idList.length,
      itemBuilder: (context, index) {
        final id = idList[index];
        final playlist = playlists.get(id);
        return FloatingMenuButton(
            icon: Icons.playlist_play,
            label: playlist.title,
            onLongPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationDialog(
                        title: AppLocalizations.of(context).get("@dialog_title_delete_playlist"),
                        onConfirmed: () {
                          // appState.setState(() {
                          //   playlist.delete();
                          //   appStorage.playlists.remove(playlist.id);
                          //   appStorage.playlistIdList.remove(playlist.id);
                          // });
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
