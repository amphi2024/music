import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';

import '../components/image/album_cover.dart';

class SelectAlbumDialog extends StatefulWidget {
  final String excepting;
  final void Function(String) onSelected;
  const SelectAlbumDialog({super.key, required this.excepting, required this.onSelected});

  @override
  State<SelectAlbumDialog> createState() => _SelectAlbumDialogState();
}

class _SelectAlbumDialogState extends State<SelectAlbumDialog> {

  List<Album> albums = [];

  @override
  void initState() {
    appStorage.albums.forEach((id, album) {
      if(widget.excepting != id) {
        albums.add(album);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    int axisCount = (MediaQuery.of(context).size.width / 250).toInt();
    if(axisCount < 2) {
      axisCount = 2;
    }
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
            Expanded(child: MasonryGridView.builder(
                itemCount: albums.length,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: axisCount),
                itemBuilder: (context, index) {
              var album = albums[index];
              return GestureDetector(
                onTap: () {
                  widget.onSelected(album.id);
                  Navigator.pop(context);
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
                      Text(
                          album.title.byContext(context)
                      ),
                      Text(
                          album.artist.name.byContext(context)
                      ),
                    ],
                  ),
                ),
              );
            }))
          ],
        ),
      ),
    );
  }
}
