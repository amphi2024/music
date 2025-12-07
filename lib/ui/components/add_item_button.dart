import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/providers.dart';
import 'package:music/utils/create_music.dart';

import '../../models/music/album.dart';
import '../../models/music/artist.dart';
import '../dialogs/edit_album_dialog.dart';
import '../dialogs/edit_artist_dialog.dart';
import '../dialogs/edit_playlist_dialog.dart';

class AddItemButton extends ConsumerWidget {
  const AddItemButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
        icon: Icon(Icons.add_circle_outline),
        onOpened: () {
          ref.read(playingBarShowingProvider.notifier).set(false);
        },
        onCanceled: () {
          ref.read(playingBarShowingProvider.notifier).set(true);
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@song")),
                onTap: () {
                  createMusic(ref);
                }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@album")),
                onTap: () {
                  showDialog(context: context, builder: (context) {
                    return EditAlbumDialog(album: Album(id: ""), ref: ref);
                  });
                }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@artist")),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return EditArtistDialog(artist: Artist(id: ""), ref: ref);
                      });
                }),
            PopupMenuItem(
                child: Text(AppLocalizations.of(context).get("@playlist")),
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return EditPlaylistDialog(playlist: Playlist(id: ""), ref: ref);
                      });
                })
          ];
        });
  }
}