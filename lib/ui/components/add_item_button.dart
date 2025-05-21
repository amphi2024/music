import 'package:flutter/material.dart';
import 'package:music/models/music/playlist.dart';

import '../../models/app_state.dart';
import '../../models/app_storage.dart';
import '../../models/music/album.dart';
import '../../models/music/artist.dart';
import '../dialogs/edit_album_dialog.dart';
import '../dialogs/edit_artist_dialog.dart';
import '../dialogs/edit_playlist_dialog.dart';

class AddItemButton extends StatelessWidget {
  const AddItemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(icon: Icon(Icons.add_circle_outline),
        onOpened: () {
          appState.setMainViewState(() {
            appState.playingBarShowing = false;
          });
        },
        onCanceled: () {
      appState.setMainViewState(() {
        appState.playingBarShowing = true;
      });
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(child: Text("Song"), onTap: () async {
              appStorage.selectMusicFilesAndSave();
            }),
            PopupMenuItem(
                child: Text("Album"), onTap: () {
              showDialog(context: context, builder: (context) {
                return EditAlbumDialog(creating: true, album: Album.created(metadata: {}, artistId: "", albumCover: []), onSave: (album) {
                  appState.setFragmentState(() {
                    appStorage.albums[album.id] = album;
                    appStorage.albumIdList.add(album.id);
                    appStorage.albumIdList.sortAlbumList();
                  });
                });
              });
            }),
            PopupMenuItem(
                child: Text("Artist"), onTap: () {
              showDialog(context: context, builder: (context) {
                return EditArtistDialog(artist: Artist.created({}), onSave: (artist) {
                  appState.setFragmentState(() {
                    appStorage.artists[artist.id] = artist;
                    appStorage.artistIdList.add(artist.id);
                    appStorage.artistIdList.sortArtistList();
                  });
                });
              });
            }),
            PopupMenuItem(child: Text("Playlist"), onTap: () {
              showDialog(context: context, builder: (context) {
                return EditPlaylistDialog(
                    playlist: Playlist.created(),
                    onSave: (playlist) {
                  appState.setState(() {
                    appStorage.playlists[playlist.id] = playlist;
                    appStorage.playlistIdList.add(playlist.id);
                    appStorage.playlistIdList.sortPlaylistList();
                  });
                });
              });
            })
          ];
        });
  }
}
