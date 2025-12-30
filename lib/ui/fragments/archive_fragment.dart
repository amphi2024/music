import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/utils/fragment_scroll_listener.dart';

import '../../providers/playlists_provider.dart';
import 'components/fragment_padding.dart';

class ArchiveFragment extends ConsumerStatefulWidget {
  const ArchiveFragment({super.key});

  @override
  ConsumerState<ArchiveFragment> createState() => _ArchiveFragmentState();
}

class _ArchiveFragmentState extends ConsumerState<ArchiveFragment> with FragmentScrollListener {

  @override
  Widget build(BuildContext context) {
    final idList = ref.watch(playlistsProvider).playlists.get("!ARCHIVE").songs;
    final songs = ref.watch(songsProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: idList.length,
      itemBuilder: (context, index) {
        final id = idList[index];
        final song = songs.get(id);
        return SongListItem(song: song, playlistId: "!ARCHIVE");
      },
    );
  }
}