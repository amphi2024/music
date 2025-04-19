import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_state.dart';
import 'package:music/models/lyrics_editing_controller.dart';
import 'package:music/models/music/lyrics.dart';
import 'package:music/models/music/song.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/ui/components/lyrics_editor.dart';
import 'package:music/ui/components/music_data_input.dart';
import 'package:music/ui/dialogs/select_album_dialog.dart';
import 'package:music/ui/dialogs/select_artist_dialog.dart';
import 'package:music/ui/views/edit_lyrics_view.dart';

class EditSongInfoDialog extends StatefulWidget {

  final Song song;
  const EditSongInfoDialog({super.key, required this.song});

  @override
  State<EditSongInfoDialog> createState() => _EditSongInfoDialogState();
}

class _EditSongInfoDialogState extends State<EditSongInfoDialog> {

  final controller = TextEditingController();
  late Song song = widget.song;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var songFile = song.files.entries.firstOrNull?.value ?? SongFile();
    print(songFile.mediaFilepath);
    var lyricsEditingController = LyricsEditingController(lyrics: songFile.lyrics, readOnly: true, songFilePath: songFile.mediaFilepath);
    var maxHeight = MediaQuery.of(context).size.height - 20;
    if(maxHeight > 500) {
      maxHeight = 500;
    }
      return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: 500,
            minHeight: 250,
            maxHeight: maxHeight
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MusicDataInput(data: song.title),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(song.artist.name.byContext(context))),
                        IconButton(onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return SelectArtistDialog(excepting: song.artistId, onSelected: (artistId) {
                              setState(() {
                                song.data["artist"] = artistId;
                                song.album.data["artist"] = artistId;
                              });
                            });
                          });
                        }, icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(song.album.title.byContext(context))),
                        IconButton(onPressed: () {
                          showDialog(context: context, builder: (context) {
                            return SelectAlbumDialog(excepting: song.albumId, onSelected: (albumId) {});
                          });
                        }, icon: Icon(Icons.edit))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        appState.setMainViewState(() {
                          appState.playingBarShowing = false;
                        });
                        Navigator.push(context, CupertinoPageRoute(builder: (context) {
                          lyricsEditingController.readOnly = false;
                          return EditLyricsView(lyricsEditingController: lyricsEditingController, onChanged: (lyrics) {
                            setState(() {
                              songFile.lyrics.data["default"] = lyrics.data.get("default");
                            });
                            songFile.save();
                          });
                        }));
                      },
                      child: SizedBox(
                        height: 500,
                        child: LyricsEditor(
                          lyricsEditingController: lyricsEditingController,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    song.save();
                    Navigator.pop(context);
                    appState.setState(() {
                      song.artist.refreshAlbums();
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
