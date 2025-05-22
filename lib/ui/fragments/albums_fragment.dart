import 'package:amphi/models/app.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/ui/components/item/album_grid_item.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../views/album_view.dart';
import 'components/fragment_padding.dart';

class AlbumsFragment extends StatefulWidget {
  const AlbumsFragment({super.key});

  @override
  State<AlbumsFragment> createState() => _AlbumsFragmentState();
}

class _AlbumsFragmentState extends State<AlbumsFragment> {
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
    int axisCount = (MediaQuery.of(context).size.width / 250).toInt();
    if (axisCount < 2) {
      axisCount = 2;
    }
    return MasonryGridView.builder(
      controller: scrollController,
      padding: fragmentPadding(context),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount),
        itemCount: appStorage.albumIdList.length,
        itemBuilder: (context, index) {
              String id = appStorage.albumIdList[index];
              var album = appStorage.albums.get(id);
            return AlbumGridItem(
                      album: album,
                      onPressed: () {
                        if(App.isDesktop() || App.isWideScreen(context)) {
                          appState.setMainViewState(() {
                            appState.fragmentTitleShowing = false;
                            appState.showingAlbumId = album.id;
                            appState.fragmentIndex = 7;
                          });
                        }
                        else {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AlbumView(album: album),
                              ));
                        }
                      },
                    onLongPressed: () {
                        showConfirmationDialog("@", () {
                          setState(() {
                            album.delete();
                            appStorage.albums.remove(id);
                            appStorage.albumIdList.remove(id);
                          });
                        });
                    },
                  );
    });
  }
}
