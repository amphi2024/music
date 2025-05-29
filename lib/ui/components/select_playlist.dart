import 'package:flutter/material.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/app_storage.dart';

class SelectPlaylist extends StatefulWidget {

  final List<String> songIdList;
  const SelectPlaylist({super.key, required this.songIdList});

  @override
  State<SelectPlaylist> createState() => _SelectPlaylistState();
}

class _SelectPlaylistState extends State<SelectPlaylist> {

  List<String> selectedPlaylists = [];

  @override
  void dispose() {
    for(var id in selectedPlaylists) {
      var playlist = appStorage.playlists.get(id);
      for(var songId in widget.songIdList) {
        playlist.songs.add(songId);
      }
      playlist.songs.sortSongList(appCacheData.sortOption(id));
      playlist.save();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appStorage.playlistIdList.length,
      itemBuilder: (context, index) {
        var id = appStorage.playlistIdList[index];
        var playlist = appStorage.playlists.get(id);
        return ListTile(
          leading: Checkbox(value: selectedPlaylists.contains(id), onChanged: (value) {
              setState(() {
                if(!selectedPlaylists.contains(id)) {
                  selectedPlaylists.add(id);
                }
                else {
                  selectedPlaylists.remove(id);
                }
              });
          }),
          title: Text(playlist.title),
        );
      },
    );
  }
}
