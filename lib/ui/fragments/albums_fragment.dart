import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:music/models/music/album.dart';
import 'package:music/ui/views/album_view.dart';

import '../../models/app_storage.dart';
import '../components/album_cover.dart';

class AlbumsFragment extends StatefulWidget {
  const AlbumsFragment({super.key});

  @override
  State<AlbumsFragment> createState() => _AlbumsFragmentState();
}

class _AlbumsFragmentState extends State<AlbumsFragment> {
  @override
  Widget build(BuildContext context) {
    List<Album> albumList = [];
    List<Widget> children = [];
    appStorage.albums.forEach((key, album) {
      albumList.add(album);
    });

    int axisCount = (MediaQuery.of(context).size.width / 250).toInt();
    if(axisCount < 2) {
      axisCount = 2;
    }
    for(int i = 0; i < axisCount; i++) {
      children.add(Container(
        height: 60,
      ));
    }
    for(var album in albumList) {
      var albumWidget = GestureDetector(
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
              Text(
                album.name["default"] ?? ""
              ),
              Text(
                  album.artist.name["default"] ?? ""
              ),
            ],
          ),
        ),
      );
      children.add(albumWidget);
    }
    return MasonryGridView(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount),
      children: children,
    );
  }
}
