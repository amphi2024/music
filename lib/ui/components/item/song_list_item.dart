import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/material.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/music/song.dart';
import 'package:music/ui/dialogs/edit_song_info_dialog.dart';

import '../../../models/player_service.dart';
import '../album_cover.dart';

class SongListItem extends StatelessWidget {

  final Song song;
  final int index;
  const SongListItem({super.key, required this.song, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        appState.setMainViewState(() {
          appState.selectedSongs = [];
        });
      },
      onTap: () {
        appState.setState(() {
          playerService.isPlaying = true;
          playerService.startPlay(song: song, i: index, localeCode: Localizations.localeOf(context).languageCode);
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
                              song.title["default"] ?? "unknown",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : null
                              ),
                            ),
                            Text(
                              song.artist.name["default"] ?? "unknown",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: playerService.nowPlaying().id == song.id ? Theme.of(context).highlightColor : null
                              ),
                            )
                          ],
                        )
                    ),
                    Visibility(
                      visible: !song.availableOnOffline(),
                        child: IconButton(onPressed: () async {
                          appWebChannel.getSongFiles(songId: song.id, onSuccess: (list) async {
                            for(var fileInfo in list) {
                              String filename = fileInfo["filename"];
                              String id = FilenameUtils.nameOnly(filename);
                              if(!filename.endsWith(".json")) {
                                appWebChannel.downloadSongFile(song: song, filename: filename, onSuccess: () {
                                  var mediaFilePath = PathUtils.join(song.path, filename);
                                  appState.setState(() {
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
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(child: Text("Remove Download")),
                          PopupMenuItem(child: Text("Add to Playlist")),
                          PopupMenuItem(child: Text("Edit Info"), onTap: () {
                            showDialog(context: context, builder: (context) {
                              return EditSongInfoDialog(song: song);
                            });
                          }),
                          PopupMenuItem(child: Text("Delete")),
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
