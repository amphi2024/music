import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';

class GenreView extends StatefulWidget {

  final Map<String, dynamic> genre;
  const GenreView({super.key, required this.genre});

  @override
  State<GenreView> createState() => _GenreViewState();
}

class _GenreViewState extends State<GenreView> {
  @override
  Widget build(BuildContext context) {
    List<Song> songList = [];
    var genreName = widget.genre.byContext(context);
    var themeData = Theme.of(context);
    appStorage.songs.forEach((key, song) {
      for(var genre in song.genre) {
        if(genre is Map<String, dynamic> && genre.containsValue(genreName)) {
          songList.add(song);
        }
      }
    });

    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.width,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: GestureDetector(
                  onLongPress: () {
                  },
                  child: Text(
                    widget.genre.byContext(context),
                    style: TextStyle(
                        fontSize: 15
                    ),
                  ),
                ),
                centerTitle: true,
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
          ]
      ),
    );
  }
}
