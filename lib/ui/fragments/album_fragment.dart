import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/fragment_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/item/song_list_item.dart';
import 'package:music/ui/fragments/components/album_fragment_title.dart';
import 'package:music/ui/fragments/components/fragment_padding.dart';
import 'package:music/utils/fragment_scroll_listener.dart';

class AlbumFragment extends ConsumerStatefulWidget {
  const AlbumFragment({super.key});

  @override
  ConsumerState<AlbumFragment> createState() => _AlbumFragmentState();
}

class _AlbumFragmentState extends ConsumerState<AlbumFragment> with FragmentViewMixin {

  late OverlayEntry overlayEntry;

  @override
  void dispose() {
    overlayEntry.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) =>
            Stack(
              children: [
                Positioned(
                    left: 205,
                    top: 5,
                    child: IconButton(onPressed: () {
                      ref.read(showingPlaylistIdProvider.notifier).set("!ALBUMS");
                      ref.read(fragmentStateProvider.notifier).setState(titleMinimized: true, titleShowing: true);
                    }, icon: Icon(Icons.arrow_back_ios_new, size: 15,))),
              ],
            ),
      );
      overlay.insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final albums = ref.watch(albumsProvider);
    final songs = ref.watch(songsProvider);
    final playlistId = ref.watch(showingPlaylistIdProvider);
    final album = albums.get(playlistId.split(",").last);
    final playlist = ref.watch(playlistsProvider).playlists.get(playlistId);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
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