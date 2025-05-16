import 'package:amphi/models/app.dart';
import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/components/select_playlist.dart';
import 'package:music/ui/dialogs/edit_song_info_dialog.dart';

import '../../../models/player_service.dart';
import '../bottom_sheet_drag_handle.dart';
import '../image/album_cover.dart';

class SongListItem extends StatelessWidget {

  final Song song;
  final String playlistId;
  const SongListItem({super.key, required this.song, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // appState.setState(() {
        //   appState.selectedSongs = [];
        // });
      },
      onTap: () {
        appState.setState(() {
          playerService.isPlaying = true;
          playerService.startPlay(song: song, localeCode: Localizations.localeOf(context).languageCode, playlistId: playlistId);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 55,
          child: Stack(
            children: [
              AnimatedOpacity(opacity: appState.selectedSongs != null ? 1 : 0,
                  curve: Curves.easeOutQuint, duration: Duration(milliseconds: 1000), child: Checkbox(value: appState.selectedSongs?.contains(song.id) ?? false, onChanged: (value) {
                    if(appState.selectedSongs?.contains(song.id) == true) {
                      appState.setMainViewState(() {
                        appState.selectedSongs?.remove(song.id);
                      });
                    }
                    else {
                      appState.setMainViewState(() {
                        appState.selectedSongs?.add(song.id);
                      });
                    }
                }),),
              AnimatedPositioned(
                curve: Curves.easeOutQuint,
                duration: Duration(milliseconds: 1000),
                left: appState.selectedSongs != null ? 45 : 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AlbumCover(
                              album: song.album,

                            ),
                          )
                      ),
                    ),
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
                                  color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : null
                              ),
                            ),
                            Text(
                              song.artist.name.byContext(context),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : null
                              ),
                            )
                          ],
                        )
                    ),
                    Visibility(
                      visible: !song.availableOnOffline() && song.transferring == null,
                        child: IconButton(onPressed: () async {
                          appState.setFragmentState(() {
                            song.transferring = true;
                          });
                          appWebChannel.getSongFiles(songId: song.id, onSuccess: (list) async {
                            for(var fileInfo in list) {
                              String filename = fileInfo["filename"];
                              String id = FilenameUtils.nameOnly(filename);
                              if(!filename.endsWith(".json")) {
                                appWebChannel.downloadSongFile(song: song, filename: filename, onSuccess: () {
                                  var mediaFilePath = PathUtils.join(song.path, filename);
                                  appState.setFragmentState(() {
                                    song.transferring = null;
                                    song.files[id]?.mediaFilepath = mediaFilePath;
                                  });
                                });
                              }
                            }
                          });
                        }, icon: Icon(
                          Icons.arrow_downward_outlined,
                          size: 13,
                        ))),
                    Visibility(
                      visible: song.transferring == true,
                        child: const CircularProgressIndicator(
                         constraints: BoxConstraints(
                           minWidth: 15,
                           minHeight: 15,
                           maxWidth: 15,
                           maxHeight: 15
                         ),
                        )),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(child: Text("Remove Download"), onTap: () {
                            appState.setFragmentState(() {
                              song.removeDownload();
                            });
                          }),
                          PopupMenuItem(child: Text("Add to Playlist"), onTap: () {
                            if(App.isDesktop() || App.isWideScreen(context)) {
                              showDialog(context: context, builder: (context) => Dialog(

                              ));
                            }
                            else {
                              appState.setMainViewState(() {
                                appState.playingBarShowing = false;
                              });
                              showModalBottomSheet(
                                  context: context, builder: (context) =>
                                  Container(
                                height: 500,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                child: Column(
                                  children: [
                                    BottomSheetDragHandle(),
                                    Expanded(child: SelectPlaylist(songId: song.id))
                                  ]
                                ),
                              )).then((value) {
                               appState.setMainViewState(() {
                                 appState.playingBarShowing = true;
                               });
                              });
                            }
                          }),
                          PopupMenuItem(child: Text("Edit Info"), onTap: () {
                            showDialog(context: context, builder: (context) {
                              return EditSongInfoDialog(song: song);
                            });
                          }),
                          PopupMenuItem(child: Text("Upload"), onTap: () {
                            appState.setFragmentState(() {
                              song.transferring = true;
                            });
                            appWebChannel.uploadSongFile(songId: song.id, filePath: song.playingFile().mediaFilepath, onSuccess: () {
                              appState.setFragmentState(() {
                                song.transferring = null;
                              });
                            });
                          }),
                          PopupMenuItem(child: Text("Delete"), onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmationDialog(
                                    title: "",
                                    onConfirmed: () {
                                      song.delete();
                                      appState.setFragmentState(() {
                                        appStorage.songs.remove(song.id);
                                        appStorage.songIdList.remove(song.id);
                                      });
                                    },
                                  );
                                });
                          }),
                        ];
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
