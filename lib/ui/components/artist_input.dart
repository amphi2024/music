import 'package:flutter/material.dart';
import 'package:music/providers/artists_provider.dart';

import '../../models/music/artist.dart';
import '../dialogs/select_artist_dialog.dart';

class ArtistInput extends StatelessWidget {

  final String label;
  final List<Artist> artists;
  final void Function(String) onArtistSelected;
  final void Function() onRemove;
  const ArtistInput({super.key, required this.artists, required this.onArtistSelected, required this.onRemove, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 15, right: 15),
      child: Row(
        children: [
          Text(label),
          Flexible(child: Text(artists.localizedName(), maxLines: 10)),
          IconButton(onPressed: () {
            showDialog(context: context, builder: (context) {
              return SelectArtistDialog(onSelected: onArtistSelected);
            });
          }, icon: Icon(Icons.add_circle_outline)),
          IconButton(onPressed: onRemove, icon: Icon(Icons.remove))
        ],
      ),
    );
  }
}