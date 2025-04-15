import 'package:flutter/material.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/ui/components/item/artist_linear_item.dart';

import '../../models/app_storage.dart';

class SelectArtistDialog extends StatefulWidget {

  final String excepting;
  final void Function(String) onSelected;
  const SelectArtistDialog({super.key, required this.excepting, required this.onSelected});

  @override
  State<SelectArtistDialog> createState() => _SelectArtistDialogState();
}

class _SelectArtistDialogState extends State<SelectArtistDialog> {

  List<Artist> artists = [];

  @override
  void initState() {
    appStorage.artists.forEach((id, artist) {
      if(widget.excepting != id) {
        artists.add(artist);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 500,
            minHeight: 250,
            maxHeight: MediaQuery.of(context).size.height - 250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.cancel_outlined)),
            Expanded(child: ListView.builder(
              itemCount: artists.length,
                itemBuilder: (context, index) {
                var artist = artists[index];
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
