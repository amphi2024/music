import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_settings.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/transfer_state.dart';
import 'package:music/providers/playing_state_provider.dart';
import 'package:music/providers/playlists_provider.dart';
import 'package:music/providers/providers.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/providers/transfers_provider.dart';
import 'package:music/ui/components/select_playlist.dart';
import 'package:music/ui/dialogs/edit_song_dialog.dart';
import 'package:music/utils/localized_title.dart';
import 'package:music/utils/screen_size.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../providers/albums_provider.dart';
import '../../../providers/artists_provider.dart';
import '../../../services/player_service.dart';
import '../bottom_sheet_drag_handle.dart';
import '../image/album_cover.dart';
import '../track_number.dart';

enum CoverStyle {cover, trackNumber}

class SongListItem extends ConsumerWidget {

  final Song song;
  final String playlistId;
  final CoverStyle coverStyle;
  const SongListItem({super.key, required this.song, required this.playlistId, this.coverStyle = CoverStyle.cover});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = playerService.playingSongId(ref) == song.id && ref.watch(playingSongsProvider).playlistId == playlistId;
    final selectedSongs = ref.watch(selectedItemsProvider);
    final album = ref.watch(albumsProvider).get(song.albumId);
    final artists = ref.watch(artistsProvider).getAll(song.artistIds);
    final selected = selectedSongs?.contains(song.id) == true;
    final transferringState = ref.watch(transfersNotifier)[song.id];

    final widget = Material(
      color: selected && isDesktop() ? Theme.of(context).highlightColor.withAlpha(150) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(8),
        highlightColor: Color.fromARGB(25, 125, 125, 125),
        splashColor: Color.fromARGB(25, 125, 125, 125),
        onLongPress: () {
          ref.read(selectedItemsProvider.notifier).startSelection();
        },
        onTap: () {
          if(ref.read(selectedItemsProvider.notifier).ctrlPressed) {
            if(selectedSongs?.contains(song.id) == true) {
              ref.read(selectedItemsProvider.notifier).removeItem(song.id);
            }
            else {
              ref.read(selectedItemsProvider.notifier).addItem(song.id);
            }
          }
          else if(ref.read(selectedItemsProvider.notifier).shiftPressed && selectedSongs!.length > 1) {
            final currentIdList = showingPlaylist(ref).songs;
            int start = currentIdList.indexOf(selectedSongs.first);
            int end = currentIdList.indexOf(song.id);

            final items = currentIdList.sublist(start, end + 1);
            ref.read(selectedItemsProvider.notifier).addAll(items);
          }
          else if(selectedSongs != null) {
            ref.read(selectedItemsProvider.notifier).endSelection();
          }
          else {
            playerService.startPlay(song: song, playlistId: playlistId, ref: ref);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            height: 55,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 5,
                  child: AnimatedOpacity(opacity: selectedSongs != null && !isDesktop() ? 1 : 0,
                    curve: Curves.easeOutQuint, duration: Duration(milliseconds: 1000),
                    child: Checkbox(value: selectedSongs?.contains(song.id) == true, onChanged: (value) {
                      if (selectedSongs?.contains(song.id) == false) {
                        ref.read(selectedItemsProvider.notifier).addItem(song.id);
                      }
                      else {
                        ref.read(selectedItemsProvider.notifier).removeItem(song.id);
                      }
                    }),),
                ),
                AnimatedPositioned(
                  curve: Curves.easeOutQuint,
                  duration: Duration(milliseconds: 1000),
                  left: selectedSongs != null && !isDesktop() ? 45 : 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      coverStyle == CoverStyle.cover ?  Padding(
                        padding: const EdgeInsets.only(left: 5, right: 10),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AlbumCover(album: album),
                          ),
                        ),
                      ) : TrackNumber(trackNumber: song.trackNumber ?? -1),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                song.title.byContext(context),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: playing ? Theme
                                        .of(context)
                                        .highlightColor : null
                                ),
                              ),
                              Text(
                                artists.localizedName(),
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    color: playing ? Theme
                                        .of(context)
                                        .highlightColor : null
                                ),
                              )
                            ],
                          )
                      ),
                      Visibility(
                          visible: !song.availableOnOffline() && transferringState == null,
                          child: IconButton(onPressed: () async {
                            for(var i = 0 ; i < song.files.length; i++) {
                              final songFile = song.files[i];
                              appWebChannel.downloadSongFile(songId: song.id, filename: songFile.filename, onProgress: (received, total) {
                                ref.read(transfersNotifier.notifier).updateTransferProgress(TransferState(songId: song.id, fileId: songFile.id, transferredBytes: received, totalBytes: total));
                              }, onSuccess: () {
                                ref.read(transfersNotifier.notifier).markTransferCompleted(songId: song.id, fileId: songFile.id);
                                song.files[i].availableOnOffline = true;
                                ref.read(songsProvider.notifier).insertSong(song);
                              });
                            }
                          }, icon: Icon(
                            Icons.arrow_downward_outlined,
                            size: 13,
                          ))),
                      if(transferringState != null) ... () {
                        final List<Widget> children = [];
                        transferringState.forEach((key, element) {
                          children.add(CircularPercentIndicator(
                              radius: 10,
                              lineWidth: 5,
                              animation: false,
                              percent: (element.transferredBytes / element.totalBytes).toDouble(),
                              progressColor: Theme.of(context).highlightColor));
                        });
                        return children;
                      } (),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) {
                          List<PopupMenuItem> list = [
                            if(appSettings.useOwnServer) ... [
                              PopupMenuItem(child: Text(AppLocalizations.of(context).get("@remove_download")), onTap: () async {
                                if(appSettings.useOwnServer) {
                                  // TODO: prevent deleting files before upload is finished
                                  await song.removeDownload();
                                  ref.read(songsProvider.notifier).insertSong(song);
                                }
                              })
                            ],
                            PopupMenuItem(child: Text(AppLocalizations.of(context).get("@add_to_playlist")), onTap: () {
                              if (isDesktopOrTablet(context)) {
                                showDialog(context: context, builder: (context) =>
                                    Dialog(
                                      child: Container(
                                        width: 300,
                                        height: 400,
                                        decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .cardColor,
                                            borderRadius: BorderRadius.circular(15)
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(onPressed: () {
                                                  Navigator.pop(context);
                                                }, icon: Icon(Icons.cancel_outlined))
                                              ],),
                                            Expanded(child: SelectPlaylist(songIdList: [song.id])),
                                          ],
                                        ),
                                      ),
                                    ));
                              }
                              else {
                                ref.read(playingBarShowingProvider.notifier).set(false);
                                showModalBottomSheet(
                                    context: context, builder: (context) =>
                                    Container(
                                      height: 500,
                                      decoration: BoxDecoration(
                                          color: Theme
                                              .of(context)
                                              .cardColor,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Column(
                                          children: [
                                            BottomSheetDragHandle(),
                                            Expanded(child: SelectPlaylist(songIdList: [song.id]))
                                          ]
                                      ),
                                    )).then((value) {
                                });
                              }
                            }),
                            PopupMenuItem(child: Text(AppLocalizations.of(context).get("@edit_song_info")), onTap: () {
                              showDialog(
                                  context: context, builder: (context) {
                                return EditSongDialog(song: song.clone(), ref: ref);
                              });
                            }),
                            PopupMenuItem(child: Text(AppLocalizations.of(context).get("@move_to_archive")), onTap: () {
                              song.archived = true;
                              song.save();
                              ref.read(songsProvider.notifier).insertSong(song);
                              ref.read(playlistsProvider.notifier).notifySongUpdate(song);
                            }),
                          ];

                          if (playlistId != "!SONGS") {
                            list.add(PopupMenuItem(child: Text(AppLocalizations.of(context).get("@remove_from_playlist")), onTap: () {
                              final playlist = ref.read(playlistsProvider).playlists.get(playlistId);
                              playlist.songs.remove(song.id);
                              playlist.save();
                              ref.read(playlistsProvider.notifier).removeItem(playlistId, song.id);
                            }));
                          }

                          list.add(PopupMenuItem(child: Text(AppLocalizations.of(context).get("move_to_trash")), onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmationDialog(
                                    title: AppLocalizations.of(context).get("dialog_title_move_to_trash"),
                                    onConfirmed: () {
                                      song.deleted = DateTime.now();
                                      song.save();
                                      ref.read(playlistsProvider.notifier).notifySongUpdate(song);
                                    },
                                  );
                                });
                          }));

                          return list;
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if(isDesktop()) {
      return Draggable<List<String>>(
        data: selectedSongs ?? [song.id],
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Icon(Icons.music_note),
        child: widget,
      );
    }
    return widget;
  }
}