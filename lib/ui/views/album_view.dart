import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/image/album_cover.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/components/track_number.dart';
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
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    widget.album.title.byContext(context),
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                widget.album.artist.name.byContext(context),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var song = songList[index];
                var textWidget = TrackNumber(trackNumber: song.trackNumber);
                return SongListItem(song: song, playlistId: "!ALBUM,${widget.album.id}", albumCover: textWidget);
              },
              childCount: songList.length,
            ),
          ),
        ],
      ),
    );
  }

}
