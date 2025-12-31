import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/utils/localized_title.dart';

import '../../providers/playlists_provider.dart';
import '../../providers/songs_provider.dart';
import '../../utils/fragment_scroll_listener.dart';
import 'components/fragment_padding.dart';

class TrashFragment extends ConsumerStatefulWidget {
  const TrashFragment({super.key});

  @override
  TrashFragmentState createState() => TrashFragmentState();
}

class TrashFragmentState extends ConsumerState<TrashFragment> with FragmentScrollListener {
  //TODO: optimize performance, improve UI/UX
  @override
  Widget build(BuildContext context) {
    final trash = ref.watch(playlistsProvider).trash;
    final songs = ref.watch(songsProvider);
    final artists = ref.watch(artistsProvider);
    final albums = ref.watch(albumsProvider);
    final playlists = ref.watch(playlistsProvider).playlists;

    List<Widget> children = [];

    for (var id in trash.songs) {
      final song = songs.get(id);
      children.add(_Item(
          title: song.title.toLocalized(),
          onRestore: () {
            song.deleted = null;
            song.save();
            ref.read(songsProvider.notifier).insertSong(song);
            ref.read(playlistsProvider.notifier).notifySongUpdate(song);
          },
          onDelete: () {
            song.delete();
            ref.read(songsProvider.notifier).removeSong(song.id);
            ref.read(playlistsProvider.notifier).deleteSong(song.id);
          }));
    }

    for (var id in trash.albums) {
      final album = albums.get(id);
      children.add(_Item(
          title: album.title.toLocalized(),
          onRestore: () {
            album.deleted = null;
            album.save();
            ref.read(albumsProvider.notifier).insertAlbum(album);
            ref.read(playlistsProvider.notifier).notifyAlbumUpdate(album);
          },
          onDelete: () {
            album.delete();
            ref.read(albumsProvider.notifier).removeAlbum(album.id);
            ref.read(playlistsProvider.notifier).deleteAlbum(album.id);
          }));
    }

    for (var id in trash.artists) {
      final artist = artists.get(id);
      children.add(_Item(
          title: artist.name.toLocalized(),
          onRestore: () {
            artist.deleted = null;
            artist.save();
            ref.read(artistsProvider.notifier).insertArtist(artist);
            ref.read(playlistsProvider.notifier).notifyArtistUpdate(artist);
          },
          onDelete: () {
            artist.delete();
            ref.read(artistsProvider.notifier).removeArtist(artist.id);
            ref.read(playlistsProvider.notifier).deleteArtist(artist.id);
          }));
    }

    for (var id in trash.playlists) {
      final playlist = playlists.get(id);
      children.add(_Item(
          title: playlist.title,
          onRestore: () {
            playlist.deleted = null;
            playlist.save();
            ref.read(playlistsProvider.notifier).insertPlaylist(playlist);
          },
          onDelete: () {
            playlist.delete();
            ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
          }));
    }

    final listView = ListView(
      padding: fragmentPadding(context),
      controller: scrollController,
      children: children,
    );

    if (Platform.isAndroid || Platform.isIOS) {
      return CupertinoScrollbar(controller: scrollController, child: listView);
    }

    return listView;
  }
}

class _Item extends StatelessWidget {
  final String title;
  final void Function() onRestore;
  final void Function() onDelete;

  const _Item({required this.title, required this.onRestore, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          PopupMenuButton(
              icon: Icon(Icons.more_vert),
              tooltip: "",
              itemBuilder: (context) {
                return [
                  PopupMenuItem(onTap: onRestore, child: Text(AppLocalizations.of(context).get("restore"))),
                  PopupMenuItem(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationDialog(
                                  title: AppLocalizations.of(context).get("dialog_title_permanently_delete"),
                                  onConfirmed: () {
                                    onDelete();
                                  });
                            });
                      },
                      child: Text(AppLocalizations.of(context).get("delete"))),
                ];
              })
        ],
      ),
    );
  }
}
