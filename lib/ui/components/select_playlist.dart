import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';

class SelectPlaylist extends ConsumerStatefulWidget {

  final List<String> songIdList;

  const SelectPlaylist({super.key, required this.songIdList});

  @override
  ConsumerState<SelectPlaylist> createState() => _SelectPlaylistState();
}

class _SelectPlaylistState extends ConsumerState<SelectPlaylist> {

  List<String> selectedPlaylists = [];

  @override
  Widget build(BuildContext context) {

    final playlistsState = ref.watch(playlistsProvider);
    final playlists = playlistsState.playlists;
    final idList = playlistsState.idList;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // for (var id in selectedPlaylists) {
        //   final playlist = playlists.get(id);
        //   for (var songId in widget.songIdList) {
        //     playlist.songs.add(songId);
        //   }
        //   playlist.songs.sortSongList(appCacheData.sortOption(id));
        //   playlist.save();
        // }
      },
      child: ListView.builder(
        itemCount: idList.length,
        itemBuilder: (context, index) {
          final id = idList[index];
          final playlist = playlists.get(id);
          return ListTile(
            leading: Checkbox(value: selectedPlaylists.contains(id), onChanged: (value) {
              setState(() {
                if (!selectedPlaylists.contains(id)) {
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
      ),
    );
  }
}
