import 'package:flutter/material.dart';
import 'package:music/models/lyrics_editing_controller.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/ui/components/lyrics_editor.dart';

import '../../models/music/lyrics.dart';

class EditSongFileDialog extends StatefulWidget {

  final SongFile songFile;
  final void Function(SongFile songFile) onUpdate;
  const EditSongFileDialog({super.key, required this.songFile, required this.onUpdate});

  @override
  State<EditSongFileDialog> createState() => _EditSongFileDialogState();
}

class _EditSongFileDialogState extends State<EditSongFileDialog> {

  late SongFile songFile = widget.songFile;
  late final titleController = TextEditingController(text: songFile.title);
  late final lyricsEditingController = LyricsEditingController(lyrics: songFile.lyrics, readOnly: false);

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 450,
        height: 450,
        child: ListView(
          children: [
            Row(
              children: [
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.cancel_outlined)),
                Expanded(child: TextField(
                  controller: titleController,
                )),
                IconButton(onPressed: () {
                  songFile.lyrics = lyricsEditingController.lyrics;
                  songFile.title = titleController.text;
                  widget.onUpdate(songFile);
                  Navigator.pop(context);
                }, icon: Icon(Icons.check_circle_outline)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lyrics:"),
                  IconButton(onPressed: () async {
                    final lyrics = await Lyrics.fromSelectedFile("default");
                    if(lyrics != null) {
                      setState(() {
                        lyricsEditingController.lyrics = lyrics;
                      });
                    }
                  }, icon: Icon(Icons.import_export_outlined))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              child: SizedBox(
                height: 300,
                child: LyricsEditor(lyricsEditingController: lyricsEditingController),
              ),
            )
            //TODO: implement starts_at, ends_at, skip, canvas_id
          ],
        ),
      ),
    );
  }
}
