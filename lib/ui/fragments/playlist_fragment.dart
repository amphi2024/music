import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/fragments/components/playlist_fragment_title.dart';
import 'package:music/utils/fragment_scroll_listener.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class PlaylistFragment extends ConsumerStatefulWidget {
  const PlaylistFragment({super.key});

  @override
  ConsumerState<PlaylistFragment> createState() => _PlaylistFragmentState();
}

class _PlaylistFragmentState extends ConsumerState<PlaylistFragment> with FragmentScrollListener {

  @override
  Widget build(BuildContext context) {
    final showingPlaylistId = ref.watch(showingPlaylistIdProvider);
    final playlist = ref.watch(playlistsProvider).playlists.get(showingPlaylistId);
    final songs = ref.watch(songsProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: playlist.songs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 5, top: 10),
              child: PlaylistFragmentTitle(playlist: playlist)
          );
        }
        else {
          var songId = playlist.songs[index - 1];
          return SongListItem(song: songs.get(songId), playlistId: playlist.id);
        }
      },
    );
  }
}
