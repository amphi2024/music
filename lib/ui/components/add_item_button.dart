import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_cache.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/models/sort_option.dart';

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
            PopupMenuItem(child: Text(AppLocalizations.of(context).get("@song")), onTap: () async {
              appStorage.selectMusicFilesAndSave();
            }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@album")), onTap: () {
              showDialog(context: context, builder: (context) {
                return EditAlbumDialog(creating: true, album: Album.created(metadata: {}, artistId: "", albumCover: []), onSave: (album) {
                  appState.setFragmentState(() {
                    appStorage.albums[album.id] = album;
                    appStorage.albumIdList.add(album.id);
                    appStorage.albumIdList.sortAlbumList(appCacheData.sortOption("!ALBUMS"));
                  });
                });
              });
            }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@artist")), onTap: () {
              showDialog(context: context, builder: (context) {
                return EditArtistDialog(artist: Artist.created({}), onSave: (artist) {
                  appState.setFragmentState(() {
                    appStorage.artists[artist.id] = artist;
                    appStorage.artistIdList.add(artist.id);
                    appStorage.artistIdList.sortArtistList(SortOption.title);
                  });
                });
              });
            }),
            PopupMenuItem(child: Text(AppLocalizations.of(context).get("@playlist")), onTap: () {
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
