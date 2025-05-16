import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/ui/components/item/album_grid_item.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../views/album_view.dart';

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

    int axisCount = (MediaQuery.of(context).size.width / 250).toInt();
    if (axisCount < 2) {
      axisCount = 2;
    }
    for (int i = 0; i < axisCount; i++) {
      children.add(Container(
        height: 60,
      ));
    }
    for (int i = 0; i < appStorage.albumIdList.length; i++) {
      String id = appStorage.albumIdList[i];
      var album = appStorage.albums.get(id);
      var albumWidget = AlbumGridItem(
          album: album,
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AlbumView(album: album),
                ));
          },
        onLongPressed: () {
            showConfirmationDialog("@", () {
              setState(() {
                album.delete();
                appStorage.albums.remove(id);
                appStorage.albumIdList.removeAt(i);
                i--;
              });
            });
        },
      );
      children.add(albumWidget);
    }

    for (int i = 0; i < axisCount; i++) {
      children.add(Container(
        height: 80,
      ));
    }
    return MasonryGridView(
      controller: scrollController,
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount),
      children: children,
    );
  }
}
