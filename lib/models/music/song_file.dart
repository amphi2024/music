import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/music/lyrics.dart';

class SongFile {
  String infoFilePath = "";
  String songFilePath = "";
  Lyrics lyrics = Lyrics();
  Map<String, dynamic> data = {};

  String get id => FilenameUtils.nameOnly(infoFilePath!);

  SongFile({
    this.infoFilePath = "",
    this.songFilePath = ""
  });

  static SongFile created({required String path, required File originalFile}) {
    var songInfoFilename = FilenameUtils.generatedFileName(".json", path);
    var songInfoFile = File(PathUtils.join(path, songInfoFilename));
    var songInfo = {
      "volume": 1.0
    };
    songInfoFile.writeAsStringSync(jsonEncode(songInfo));

    var songFilename = "${FilenameUtils.nameOnly(songInfoFilename)}.${FilenameUtils.extensionName(originalFile.path)}";
    var songFile = File(PathUtils.join(path, songFilename));
    songFile.writeAsBytesSync(originalFile.readAsBytesSync());

    return SongFile(
      infoFilePath: songInfoFile.path,
      songFilePath: songFile.path
    );
  }

  void getData() async {
    var infoFile = File(infoFilePath);
    var jsonData = await infoFile.readAsString();
    data = jsonDecode(jsonData);
    var lyricsData = data["lyrics"];
    if(lyricsData is Map<String, dynamic>) {
      lyricsData.forEach((key, value) {
        if(value is List<dynamic>) {
          for(var line in value) {
            if(line is Map<String, dynamic>) {
              lyrics.data.get("default").add(LyricLine(
                  startsAt: line["startsAt"],
                  endsAt: line["endsAt"],
                  text: line["text"]
              ));
            }
            else {
              lyrics.data.get("default").add(LyricLine(
                  text: line.toString()
              ));
            }
          }
        }
        else {
          lyrics.data.get("default").add(LyricLine(
              text: lyricsData.toString()
          ));
        }
      });


    }
    else {
      lyrics.data.get("default").add(LyricLine(
          text: lyricsData.toString()
      ));
    }

  }

  void save() async {
    var infoFile = File(infoFilePath);
    data["lyrics"] = lyrics.toMap();
    await infoFile.writeAsString(jsonEncode(data));
  }
}