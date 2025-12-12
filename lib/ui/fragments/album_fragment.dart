import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/fragments/components/album_fragment_title.dart';
import 'package:music/ui/fragments/components/fragment_padding.dart';

class AlbumFragment extends ConsumerWidget {
  const AlbumFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    final songs = ref.watch(songsProvider);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    final album = albums.get(playlistId
        .split(",")
        .last);
    final playlist = ref
        .watch(playlistsProvider)
        .playlists
        .get(playlistId);

    return ListView.builder(
      padding: fragmentPadding(context),
      itemCount: playlist.songs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 5, top: 50),
            child: AlbumFragmentTitle(album: album),
          );
        }
        else {
          final songId = playlist.songs[index - 1];
          return SongListItem(song: songs.get(songId), playlistId: "!ALBUM,${album.id}", coverStyle: CoverStyle.trackNumber);
        }
      },
    );
  }
}