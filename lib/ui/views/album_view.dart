import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/music.dart';
import 'package:music/ui/components/album_cover.dart';

class AlbumView extends StatelessWidget {

  final Album album;
  const AlbumView({super.key, required this.album});

  @override
  Widget build(BuildContext context) {

    List<Music> musicList = [];
    for(var musicId in album.music) {
      musicList.add(appStorage.music[musicId]!);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width + 150,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                  album.name.byLocale(context),
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              centerTitle: true,
              background: Center(
                child: SizedBox(
                  width: 250,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AlbumCover(album: album, fit: BoxFit.cover,)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                title: Text(musicList[index].title.byLocale(context)),
              ),
              childCount: musicList.length,  // Number of songs
            ),
          ),
        ],
        // children: [
        //   Positioned(
        //       left: 0,
        //       top: 0,
        //       child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
        //
        //   })),
        //
        // ],
      ),
    );
  }
}
