import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/ui/components/item/album_grid_item.dart';
import 'package:music/utils/fragment_scroll_listener.dart';

import '../../utils/screen_size.dart';
import '../pages/album_page.dart';
import 'components/fragment_padding.dart';

class AlbumsFragment extends ConsumerStatefulWidget {
  const AlbumsFragment({super.key});

  @override
  ConsumerState<AlbumsFragment> createState() => _AlbumsFragmentState();
}

class _AlbumsFragmentState extends ConsumerState<AlbumsFragment> with FragmentViewMixin {

  @override
  Widget build(BuildContext context) {
    int axisCount = (MediaQuery
        .of(context)
        .size
        .width / 250).toInt();
    if (axisCount < 2) {
      axisCount = 2;
    }

    final idList = ref.watch(playlistsProvider).playlists.get("!ALBUMS").songs;
    final albums = ref.watch(albumsProvider);

    return MasonryGridView.builder(
        controller: scrollController,
        padding: fragmentPadding(context),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount),
        itemCount: idList.length,
        itemBuilder: (context, index) {
          final id = idList[index];
          final album = albums.get(id);
          return AlbumGridItem(
            album: album,
            onPressed: () {
              if (isDesktopOrTablet(context)) {
                ref.read(showingPlaylistIdProvider.notifier).set("!ALBUM,$id");
                ref.read(fragmentStateProvider.notifier).setTitleShowing(false);
              }
              else {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => AlbumPage(album: album),
                    ));
              }
            },
            onLongPressed: () {
              if(Platform.isAndroid || Platform.isIOS) {
                ref.read(selectedItemsProvider.notifier).startSelection();
              }
            },
          );
        });
  }
}
