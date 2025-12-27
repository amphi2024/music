import 'dart:math';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/models/music/playlist.dart';
import 'package:music/providers/albums_provider.dart';
import 'package:music/providers/artists_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/ui/components/image/artist_profile_image.dart';
import 'package:music/ui/dialogs/edit_artist_dialog.dart';
import 'package:music/ui/fragments/components/floating_button.dart';
import 'package:music/utils/localized_title.dart';

import '../../services/player_service.dart';
import '../components/image/album_cover.dart';
import '../components/item/song_list_item.dart';
import 'components/fragment_padding.dart';

class ArtistFragment extends ConsumerWidget {
  const ArtistFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showingArtistId = ref
        .watch(showingPlaylistIdProvider)
        .split(",")
        .last;
    final artists = ref.watch(artistsProvider);
    final albums = ref.watch(albumsProvider);
    final artist = artists.get(showingArtistId);
    final String playlistId = "!ARTIST,${artist.id}";
    final playlists = ref
        .watch(playlistsProvider)
        .playlists;
    final playlist = playlists.get(playlistId);
    final searchKeyword = ref.watch(searchKeywordProvider);

    return ListView.builder(
      padding: fragmentPadding(context),
      itemCount: playlist.songs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 15),
            child: Column(
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: ArtistProfileImage(artist: artist),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(artist.name.byContext(context), textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FloatingButton(icon: Icons.play_arrow, onPressed: () {
                      final artistPlaylist = Playlist(id: "!ARTIST,${artist.id}");
                      for(var id in playlist.songs) {
                        final albumPlaylist = playlists.get("!ALBUM,$id");
                        artistPlaylist.songs.addAll(albumPlaylist.songs);
                      }
                      if(artistPlaylist.songs.isNotEmpty) {
                        final song = ref.read(songsProvider).get(artistPlaylist.songs[0]);
                        playerService.startPlayFromPlaylist(song: song, playlist: artistPlaylist, ref: ref, shuffle: false);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: FloatingButton(icon: Icons.shuffle, onPressed: () {
                        final artistPlaylist = Playlist(id: "!ARTIST,${artist.id}");
                        for(var id in playlist.songs) {
                          final albumPlaylist = playlists.get("!ALBUM,$id");
                          artistPlaylist.songs.addAll(albumPlaylist.songs);
                        }
                        if(artistPlaylist.songs.isNotEmpty) {
                          final index = Random().nextInt(artistPlaylist.songs.length);
                          final song = ref.read(songsProvider).get(artistPlaylist.songs[index]);
                          playerService.startPlayFromPlaylist(song: song, playlist: artistPlaylist, ref: ref, shuffle: true);
                        }
                      }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text(AppLocalizations.of(context).get("edit")), onTap: () {
                          showDialog(context: context, builder: (context) {
                            return EditArtistDialog(artist: artist, ref: ref);
                          });
                        }),
                        PopupMenuItem(child: Text(AppLocalizations.of(context).get("move_to_trash")), onTap: () {
                          showDialog(context: context, builder: (context) {
                            return ConfirmationDialog(
                              title: AppLocalizations.of(context).get("dialog_title_move_to_trash"),
                              onConfirmed: () {
                                artist.deleted = DateTime.now();
                                artist.save();
                                ref.read(artistsProvider.notifier).insertArtist(artist);
                                ref.read(playlistsProvider.notifier).notifyArtistUpdate(artist);
                              },
                            );
                          });
                        })
                      ];
                    })
                  ],
                )
              ],
            ),
          );
        }
        else {
          final albumId = playlist.songs[index - 1];
          final album = albums.get(albumId);
          final albumPlaylist = playlists.get("!ALBUM,$albumId");

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
                if (searchKeyword != null &&
                    !song.title
                        .toLocalized()
                        .toLowerCase()
                        .contains(searchKeyword.toLowerCase())) {
                  return const SizedBox.shrink();
                }
                return SongListItem(
                    song: song,
                    playlistId: playlistId,
                    coverStyle: CoverStyle.trackNumber
                );
              }),
            ],
          );
        }
      },
    );
  }
}
