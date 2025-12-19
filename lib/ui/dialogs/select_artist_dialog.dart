import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/ui/components/item/artist_linear_item.dart';
import 'package:music/ui/components/search_bar.dart';
import 'package:music/utils/localized_title.dart';

class SelectArtistDialog extends ConsumerStatefulWidget {
  final void Function(String) onSelected;
  const SelectArtistDialog({super.key, required this.onSelected});

  @override
  SelectArtistDialogState createState() => SelectArtistDialogState();
}

class SelectArtistDialogState extends ConsumerState<SelectArtistDialog> {

  String searchKeyword = "";

  @override
  Widget build(BuildContext context) {
    final artists = ref.watch(artistsProvider);
    var idList = [...ref
        .watch(playlistsProvider)
        .playlists
        .get("!ARTISTS")
        .songs];
    if(searchKeyword.isNotEmpty) {
      idList = idList.where((id) {
        return artists.get(id).name.toLocalized().toLowerCase().contains(searchKeyword.toLowerCase());
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
            Expanded(child: ListView.builder(
                itemCount: idList.length,
                itemBuilder: (context, index) {
                  final artist = artists.get(idList[index]);
                  return ArtistLinearItem(artist: artist, onLongPressed: () {}, onPressed: () {
                    widget.onSelected(artist.id);
                    Navigator.pop(context);
                  });
                }))
          ],
        ),
      ),
    );
  }
}
