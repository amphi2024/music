import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/ui/dialogs/edit_song_file_dialog.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:music/utils/screen_size.dart';

class EditSongFiles extends ConsumerStatefulWidget {

  final Song song;
  final void Function(SongFile songFile, File file) onFileSelected;
  final void Function(String id) onRemoveFile;
  final void Function(SongFile songFile) onUpdateFile;
  const EditSongFiles({super.key, required this.song, required this.onFileSelected, required this.onRemoveFile, required this.onUpdateFile});

  @override
  ConsumerState<EditSongFiles> createState() => _EditSongFilesState();
}

class _EditSongFilesState extends ConsumerState<EditSongFiles> {

  final scrollController = ScrollController();
  Map<String, Player> players = {};

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    players.forEach((key, value) {
      value.dispose();
    });
  }

  @override
  void initState() {
    super.initState();
    for (var songFile in widget.song.files) {
      final player = Player();
      if(songFile.availableOnOffline) {
        player.open(Media(songMediaFilePath(widget.song.id, songFile.filename)), play: false);
      }
      else {
        player.open(Media("${appWebChannel.serverAddress}/music/${widget.song.id}/files/${songFile.filename}", httpHeaders: {
          "Authorization": appWebChannel.token
        }), play: false);
      }
      players[songFile.id] = player;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isWideScreen(context) ? 150 : 175,
      child: Scrollbar(
          controller: scrollController,
          child: ListView.builder(
            itemCount: widget.song.files.length + 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (widget.song.files.length == index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowMultiple: true,
                          allowedExtensions: ["mp3", "flac", "m4a", "wav", "aac", "ogg", "wma", "mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "mpeg"]);
                      if (result != null) {
                        for (var platformFile in result.files) {
                          final filePath = platformFile.path;
                          if (filePath != null) {
                            final file = File(filePath);
                            final songFileId = generatedSongFileId(widget.song);
                            final songFile = SongFile(id: songFileId, filename: "${songFileId}.${PathUtils.extension(file.path)}".replaceAll("..", "."));
                            final player = Player();
                            player.open(Media(filePath), play: false);
                            players[songFileId] = player;
                            widget.onFileSelected(songFile, file);
                          }
                        }
                      }
                    }, icon: Icon(Icons.add_circle_outline))
                  ],
                );
              }
              final songFile = widget.song.files[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .navigationBarTheme
                          .backgroundColor,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(songFile.title),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(".${widget.song.files[index].format}"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: () {
                            showDialog(context: context, builder: (context) {
                              return EditSongFileDialog(
                                songFile: songFile,
                                onUpdate: (songFile) {
                                  widget.onUpdateFile(songFile);
                                },
                              );
                            });
                          }, icon: Icon(Icons.edit)),
                          IconButton(onPressed: () {
                            setState(() {
                              players[songFile.id]?.playOrPause();
                            });
                          }, icon: Icon(players[songFile.id]?.state.playing == true ? Icons.pause : Icons.play_arrow)),
                          IconButton(onPressed: () {
                            showDialog(context: context, builder: (context) {
                              return ConfirmationDialog(title: AppLocalizations.of(context).get("dialog_title_remove_song_file"), onConfirmed: () {
                                widget.onRemoveFile(songFile.id);
                              });
                            });
                          }, icon: Icon(Icons.cancel_outlined))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 8),
                        child: Row(
                          children: [
                            Icon(Icons.volume_down),
                            Expanded(
                              child: Slider(
                                  min: 0,
                                  max: 200,
                                  value: players[songFile.id]?.state.volume ?? 0, onChanged: (value) {
                                    setState(() {
                                      players[songFile.id]?.setVolume(value);
                                    });
                              }),
                            ),
                            Icon(Icons.volume_up)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}