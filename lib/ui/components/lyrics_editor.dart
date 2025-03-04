import 'package:audioplayers/audioplayers.dart';
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

  AudioPlayer? audioPlayer;
  double position = 0;
  double duration = 0;

  Future<void> initAudioPlayer() async {
    audioPlayer = AudioPlayer();
    await audioPlayer?.setSource(DeviceFileSource(
        widget.lyricsEditingController.songFilePath
    ));
    var d = await audioPlayer?.getDuration();
    setState(() {
      duration = d?.inMilliseconds.toDouble() ?? 0;
    });
    audioPlayer?.onPositionChanged.listen((value) {
      var p = value.inMilliseconds.toDouble();
      if(p < duration) {
        setState(() {
          position = p;
        });
      }
    });
  }

  Future<void> togglePlay() async {
    if(audioPlayer?.state == PlayerState.playing) {
      await audioPlayer?.pause();
    }
    else {
      await audioPlayer?.resume();
    }
    setState(() {

    });
  }

  @override
  void dispose() {
    widget.lyricsEditingController.lyrics.disposeTextControllers();
    super.dispose();
  }

  @override
  void initState() {
    if(!widget.lyricsEditingController.readOnly) {
      initAudioPlayer();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var readOnly = widget.lyricsEditingController.readOnly;
    var lyrics = widget.lyricsEditingController.lyrics;
    if(lyrics.lines.isEmpty) {
      if(widget.lyricsEditingController.readOnly) {
        return Text("Empty Lyrics");
      }
    }
    else if(readOnly) {
      return ListView.builder(
          itemCount: lyrics.lines.length,
          itemBuilder: (context, index) {
            var text = lyrics.lines[index].text;
            if(text.isEmpty) {
              text = "Empty Lyrics";
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
                final item = lyrics.lines.removeAt(oldIndex);
                lyrics.lines.insert(newIndex, item);
              });
            },
              itemCount: lyrics.lines.length,
              itemBuilder: (context, index) {
                var lyricLine = lyrics.lines[index];
                var focusing = false;
                if(lyricLine.startsAt <= position && lyricLine.endsAt >= position) {
                  focusing = true;
                }
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
                          style: TextStyle(
                              color: focusing ? Theme.of(context).highlightColor : null,
                            fontWeight: focusing ? FontWeight.bold : null
                          ),
                          decoration: InputDecoration(
                            hintText: "Lyrics"
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100,
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
                      width: 100,
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
        Visibility(
          visible: !readOnly,
          child: Slider(value: position, max: duration, min: 0, onChanged: (value) {
            audioPlayer?.seek(Duration(milliseconds: value.toInt()));
          }),
        ),
        Visibility(
          visible: !readOnly,
          child: IconButton(onPressed: () {
            togglePlay();
          }, icon: Icon(audioPlayer?.state == PlayerState.playing ? Icons.pause : Icons.play_arrow)),
        ),
        Visibility(
          visible: !readOnly,
          child: IconButton(onPressed: () {
            setState(() {
             lyrics.lines.add(LyricLine());
            });
          }, icon: Icon(Icons.add_circle_outline)),
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