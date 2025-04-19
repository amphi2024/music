import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/album_cover.dart';
import 'package:music/ui/dialogs/edit_album_dialog.dart';

class AlbumView extends StatefulWidget {
  final Album album;

  const AlbumView({super.key, required this.album});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  @override
  Widget build(BuildContext context) {
    List<Song> songList = [];
    for (var id in widget.album.songs) {
      var song = appStorage.songs[id];
      if (song != null) {
        songList.add(song);
      }
    }

    var themeData = Theme.of(context);

    var imageSize = MediaQuery.of(context).size.width - 100;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width + 80,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: GestureDetector(
                onLongPress: () {
                  showDialog(context: context, builder: (context) => EditAlbumDialog(album: widget.album, onSave: (a) {
                    setState(() {

                    });
                  }));
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.album.title.byContext(context),
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              centerTitle: true,
              background: Center(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AlbumCover(
                        album: widget.album,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var song = songList[index];
                return ListTile(
                title: Text(song.title.byContext(context)),
                leading: Text(
                    song.trackNumber.toString(),
                  style: TextStyle(
                    fontSize: themeData.textTheme.bodyMedium?.fontSize,
                    color: themeData.dividerColor
                  ),
                ),
              );
              },
              childCount: songList.length,
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
