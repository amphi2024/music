import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/ui/components/item/album_grid_item.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/playlists_provider.dart';
import '../components/search_bar.dart';

class SelectAlbumDialog extends ConsumerStatefulWidget {
  final void Function(String) onSelected;

  const SelectAlbumDialog({super.key, required this.onSelected});

  @override
  ConsumerState<SelectAlbumDialog> createState() => _SelectAlbumDialogState();
}

class _SelectAlbumDialogState extends ConsumerState<SelectAlbumDialog> {

  String searchKeyword = "";

  @override
  Widget build(BuildContext context) {

    int axisCount = (MediaQuery
        .of(context)
        .size
        .width / 250).toInt();
    if (axisCount < 2) {
      axisCount = 2;
    }

    final albums = ref.watch(albumsProvider);
    var idList = [...ref
        .watch(playlistsProvider)
        .playlists
        .get("!ALBUMS")
        .songs];
    if(searchKeyword.isNotEmpty) {
      idList = idList.where((id) {
        final album = albums.get(id);
        final artists = ref.read(artistsProvider).getAll(album.artistIds);
        return albums.get(id).title.toLocalized().toLowerCase().contains(searchKeyword.toLowerCase()) || artists.localizedName().toLowerCase().contains(searchKeyword.toLowerCase());
      }).toList();
    }
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 500,
            minHeight: 250,
            maxHeight: MediaQuery
                .of(context)
                .size
                .height - 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedSearchBar(
                      onChanged: (text) {
                        setState(() {
                          searchKeyword = text;
                        });
                      },
                    ),
                  ),
                ),
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.cancel_outlined)),
              ],
            ),
            Expanded(child: MasonryGridView.builder(
                itemCount: idList.length,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: axisCount),
                itemBuilder: (context, index) {
                  final id = idList[index];
                  final album = albums.get(id);
                  return AlbumGridItem(album: album, onPressed: () {
                        widget.onSelected(id);
                        Navigator.pop(context);
                  });
                }))
          ],
        ),
      ),
    );
  }
}
