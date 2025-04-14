import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';

import '../views/album_view.dart';
import 'album_cover.dart';

class AlbumGridItem extends StatelessWidget {
  final Album album;
  const AlbumGridItem({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) => AlbumView(album: album)));
      },
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
                album.name.byContext(context),
                maxLines: 3,
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
                album.artist.name.byContext(context)
            ),
          ],
        ),
      ),
    );
  }
}
