import 'package:flutter/material.dart';
import 'package:music/models/app_storage.dart';

class SelectPlaylist extends StatefulWidget {

  final String songId;
  const SelectPlaylist({super.key, required this.songId});

  @override
  State<SelectPlaylist> createState() => _SelectPlaylistState();
}

class _SelectPlaylistState extends State<SelectPlaylist> {

  List<String> selectedPlaylists = [];

  @override
  void dispose() {
    for(var id in selectedPlaylists) {
      var playlist = appStorage.playlists.get(id);
      playlist.songs.add(widget.songId);
      playlist.songs.sortSongList();
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
