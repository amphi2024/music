import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';

import '../image/album_cover.dart';

class AlbumGridItem extends StatelessWidget {
  final Album album;
  final bool showArtistName;
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  const AlbumGridItem({super.key, required this.album, this.onPressed, this.onLongPressed, this.showArtistName = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AlbumCover(album: album),
              ),
            ),
            SizedBox(
              height: 70,
              child: Text(
                album.title.byContext(context),
                maxLines: 3,
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Visibility(
              visible: showArtistName,
              child: Text(
                  album.artist.name.byContext(context)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
