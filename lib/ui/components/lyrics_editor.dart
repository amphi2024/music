import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:music/models/lyrics_editing_controller.dart';
import 'package:music/models/music/lyrics.dart';

class LyricsEditor extends StatefulWidget {

  final LyricsEditingController lyricsEditingController;
  const LyricsEditor({super.key, required this.lyricsEditingController});

  @override
  State<LyricsEditor> createState() => _LyricsEditorState();
}

class _LyricsEditorState extends State<LyricsEditor> {

  @override
  void dispose() {
    widget.lyricsEditingController.lyrics.disposeTextControllers();
    super.dispose();
  }

  @override
  void initState() {
    if(widget.lyricsEditingController.lyrics.data.get("default").isEmpty && !widget.lyricsEditingController.readOnly) {
      widget.lyricsEditingController.lyrics.data.get("default").add(LyricLine());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var readOnly = widget.lyricsEditingController.readOnly;
    var lyrics = widget.lyricsEditingController.lyrics;
    if(lyrics.data.get("default").isEmpty) {
      if(widget.lyricsEditingController.readOnly) {
        return Text(AppLocalizations.of(context).get("@no_lyrics_available"));
      }
    }
    else if(readOnly) {
      return ListView.builder(
          itemCount: lyrics.data.get("default").length,
          itemBuilder: (context, index) {
            var text = lyrics.data.get("default")[index].text;
            if(text.isEmpty && lyrics.data.get("default").isEmpty) {
              text = AppLocalizations.of(context).get("@no_lyrics_available");
            }
        return Text(text);
      });
    }
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if(oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = lyrics.data.get("default").removeAt(oldIndex);
                lyrics.data.get("default").insert(newIndex, item);
              });
            },
              itemCount: lyrics.data.get("default").length,
              itemBuilder: (context, index) {
                var lyricLine = lyrics.data.get("default")[index];
            return Column(
              key: Key(index.toString()),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: lyricLine.lyricsTextController,
                          onChanged: (text) {
                            lyricLine.text = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Lyrics"
                          ),
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {
                      showDialog(context: context, builder: (context) => ConfirmationDialog(title: AppLocalizations.of(context).get("@dialog_title_delete_lyric"), onConfirmed: () {
                        setState(() {
                          widget.lyricsEditingController.lyrics.data.get("default").removeAt(index);
                        });
                      }));
                    }, icon: Icon(Icons.remove))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 125,
                      child: TextField(
                        controller: lyricLine.startTimeController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: "00:00.00",
                        ),
                        onChanged: (text) {
                          lyricLine.startsAt = convertTimeToMilliseconds(text);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: TextField(
                        controller: lyricLine.endTimeController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: "00:00.00"
                        ),
                        onChanged: (text) {
                          lyricLine.endsAt = convertTimeToMilliseconds(text);
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          }),
        ),
      ],
    );
  }
}

int convertTimeToMilliseconds(String time) {
  // Split the time string by the colon ":"
  List<String> timeParts = time.split(':');

  // Check if there are hours, minutes, and seconds
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  int milliseconds = 0;

  // Assign values based on the number of parts
  if (timeParts.length == 3) {
    hours = int.parse(timeParts[0]);
    minutes = int.parse(timeParts[1]);

    // Split the seconds part to handle milliseconds
    List<String> secParts = timeParts[2].split('.');
    seconds = int.parse(secParts[0]);
    milliseconds = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;
  } else if (timeParts.length == 2) {
    minutes = int.parse(timeParts[0]);

    // Split the seconds part to handle milliseconds
    List<String> secParts = timeParts[1].split('.');
    seconds = int.parse(secParts[0]);
    milliseconds = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;
  } else if (timeParts.length == 1) {
    // Handle cases where only seconds and milliseconds are provided
    List<String> secParts = timeParts[0].split('.');
    seconds = int.parse(secParts[0]);
    milliseconds = secParts.length > 1 ? int.parse(secParts[1].padRight(3, '0').substring(0, 3)) : 0;
  }

  // Convert to total milliseconds: (hours * 3600 * 1000) + (minutes * 60 * 1000) + (seconds * 1000) + milliseconds
  int totalMilliseconds = (hours * 3600 * 1000) + (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;

  return totalMilliseconds;
}