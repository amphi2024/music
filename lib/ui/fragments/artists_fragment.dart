import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/ui/components/item/artist_linear_item.dart';
import 'package:music/ui/views/artist_view.dart';

import '../../models/app_state.dart';

class ArtistsFragment extends StatefulWidget {
  const ArtistsFragment({super.key});

  @override
  State<ArtistsFragment> createState() => _ArtistsFragmentState();
}

class _ArtistsFragmentState extends State<ArtistsFragment> {
  var scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    appState.setFragmentState = setState;
    scrollController.addListener(() {
      appState.setMainViewState(() {
        appState.fragmentTitleMinimized = scrollController.offset > 60 && appState.selectedSongs == null;
      });
    });
    appState.requestScrollToTop = () {
      scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add(Container(
      height: 60,
    ));
    for (int i = 0; i < appStorage.artistIdList.length; i++) {
      var id = appStorage.artistIdList[i];
      var artist = appStorage.artists.get(id);
      var artistWidget = ArtistLinearItem(
          artist: artist,
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => ArtistView(artist: artist)));
          },
          onLongPressed: () {
            showConfirmationDialog("@", () {
              artist.delete();
              setState(() {
                appStorage.artists.remove(artist.id);
                appStorage.artistIdList.removeAt(i);
              });
            });
          });
      children.add(artistWidget);
    }

    children.add(Container(
      height: 80,
    ));
    return ListView(
      controller: scrollController,
      children: children,
    );
  }
}
