import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/fragment_scroll_listener.dart';
import 'package:music/utils/localized_title.dart';

import '../../models/app_storage.dart';
import '../../providers/fragment_provider.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class ArtistFragment extends ConsumerStatefulWidget {
  const ArtistFragment({super.key});

  @override
  ConsumerState<ArtistFragment> createState() => _ArtistFragmentState();
}

class _ArtistFragmentState extends ConsumerState<ArtistFragment> with FragmentViewMixin {

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
                      ref.read(fragmentStateProvider.notifier).setState(titleShowing: true, titleMinimized: false);
                      ref.read(showingPlaylistIdProvider.notifier).set("!ARTISTS");
                    }, icon: Icon(Icons.arrow_back_ios_new, size: 15,))),
              ],
            ),
      );
      overlay.insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showingArtistId = ref.watch(showingPlaylistIdProvider).split(",").last;
    final artists = ref.watch(artistsProvider);
    final artist = artists.get(showingArtistId);
    final String playlistId = "!ARTIST,${artist.id}";
    final playlists = ref.watch(playlistsProvider).playlists;
    final playlist = playlists.get(playlistId);

    return ListView.builder(
      padding: fragmentPadding(context),
      controller: scrollController,
      itemCount: playlist.songs.length + 3,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: ArtistProfileImage(artist: artist),
                  ),
                ),
              ],
            ),
          );
        }
        else if (index == 1) {
          return GestureDetector(
            onLongPress: () {
              showDialog(context: context, builder: (context) =>
                  EditArtistDialog(artist: artist, ref: ref));
            },
            child: Text(artist.name.byContext(context), textAlign: TextAlign.center, style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),),
          );
        }
        else if (index == 2) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingButton(icon: Icons.play_arrow, onPressed: () {
                // var albumId = artist.albums.firstOrNull;
                // if (albumId != null) {
                //   var songId = appStorage.albums
                //       .get(albumId)
                //       .songs
                //       .firstOrNull;
                //   if (songId != null) {
                //     // startPlay(song: song, playlistId: playlistId, ref: ref, shuffle: false);
                //     // appState.setState(() {
                //     //   playerService.isPlaying = true;
                //     //   playerService.shuffled = false;
                //     //   playerService.startPlay(song: ref.watch(songsProvider).get(songId), playlistId: playlistId);
                //     // });
                //   }
                // }
              }),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                  // var albumId = artist.albums.firstOrNull;
                  // if (albumId != null) {
                  //   var songId = appStorage.albums
                  //       .get(albumId)
                  //       .songs
                  //       .firstOrNull;
                  //   if (songId != null) {
                  //     // appState.setState(() {
                  //     //   playerService.isPlaying = true;
                  //     //   playerService.startPlay(song: ref.watch(songsProvider).get(songId), playlistId: playlistId, shuffle: true);
                  //     // });
                  //   }
                  // }
                }),
              ),
            ],
          );
        }
        else {
          final albumId = playlist.songs[index - 3];
          final album = appStorage.albums.get(albumId);
          final albumPlaylist = playlists.get("!ALBUM,$album");

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 30),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AlbumCover(album: album),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          album.title.byContext(context),
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...albumPlaylist.songs.map((songId) {
                final song = ref.watch(songsProvider).get(songId);
                return SongListItem(
                  song: song,
                  playlistId: playlistId,
                  coverStyle: CoverStyle.cover
                );
              }),
            ],
          );
        }
      },
    );
  }
}
