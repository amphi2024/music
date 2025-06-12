import 'package:amphi/models/app.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/fragment_index.dart';
import 'package:music/ui/components/item/artist_linear_item.dart';
import 'package:music/ui/views/artist_view.dart';

import '../../models/app_state.dart';
import 'components/fragment_padding.dart';

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
      if(scrollController.offset > 60 && appState.selectedSongs == null) {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = true;
        });
      }
      else {
        appState.setMainViewState(() {
          appState.fragmentTitleMinimized = false;
        });
      }
    });
    appState.requestScrollToTop = () {
      scrollController.animateTo(0, duration: Duration(milliseconds: 750), curve: Curves.easeOutQuint);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: appStorage.artistIdList.length,
      itemBuilder: (context, index) {
            var id = appStorage.artistIdList[index];
            var artist = appStorage.artists.get(id);
            return ArtistLinearItem(
                artist: artist,
                onPressed: () {
                  if(App.isWideScreen(context) || App.isDesktop()) {
                    appState.setMainViewState(() {
                      appState.fragmentIndex = FragmentIndex.artist;
                      appState.fragmentTitleShowing = false;
                      appState.showingArtistId = artist.id;
                    });
                  }
                  else {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => ArtistView(artist: artist)));
                  }
                },
                onLongPressed: () {
                    showConfirmationDialog("@dialog_title_delete_artist", () {
                      artist.delete();
                      setState(() {
                        appStorage.artists.remove(artist.id);
                        appStorage.artistIdList.remove(artist.id);
                      });
                    });
                });
      },
    );
  }
}
