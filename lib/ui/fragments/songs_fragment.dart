import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/fragments/components/fragment_padding.dart';
import 'package:music/utils/fragment_scroll_listener.dart';

class SongsFragment extends ConsumerStatefulWidget {
  const SongsFragment({super.key});

  @override
  ConsumerState<SongsFragment> createState() => _SongsFragmentState();
}

class _SongsFragmentState extends ConsumerState<SongsFragment> with FragmentViewMixin {

  @override
  Widget build(BuildContext context) {
    final idList = ref.watch(playlistsProvider).playlists.get("!SONGS").songs;
    final songs = ref.watch(songsProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: idList.length,
      itemBuilder: (context, index) {
        final id = idList[index];
        final song = songs.get(id);
        return SongListItem(song: song, playlistId: "!SONGS");
      },
    );
  }
}
