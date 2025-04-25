import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/lyrics.dart';

class SongFile {
  String infoFilepath = "";
  String mediaFilepath = "";
  Lyrics lyrics = Lyrics();
  Map<String, dynamic> data = {};
  bool get mediaFileExists => mediaFilepath.isNotEmpty;

  late String id;
  late String songId;

  String get url {
    final filename = PathUtils.basename(mediaFilepath);
    return "${appWebChannel.serverAddress}/songs//${filename}";
  }

  SongFile({
    this.infoFilepath = "",
    this.mediaFilepath = ""
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

    var result = SongFile(
      infoFilepath: songInfoFile.path,
      mediaFilepath: songFile.path
    );
    result.id = FilenameUtils.nameOnly(songFilename);
    return result;
  }

  void getData() async {
    var infoFilename = PathUtils.basename(infoFilepath);
    id = FilenameUtils.nameOnly(infoFilename);
    var infoFile = File(infoFilepath);
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

  Future<void> save() async {
    var infoFile = File(infoFilepath);
    data["lyrics"] = lyrics.toMap();
    await infoFile.writeAsString(jsonEncode(data));
  }
}