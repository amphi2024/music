import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/ui/components/item/album_grid_item.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';

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
    if(axisCount < 2) {
      axisCount = 2;
    }
    for(int i = 0; i < axisCount; i++) {
      children.add(Container(
        height: 60,
      ));
    }
    for(var id in appStorage.albumIdList) {
      var albumWidget = AlbumGridItem(album: appStorage.albums.get(id));
      children.add(albumWidget);
    }

    for(int i = 0; i < axisCount; i++) {

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
