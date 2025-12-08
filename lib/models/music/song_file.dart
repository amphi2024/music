import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/music/lyrics.dart';

import '../../utils/media_file_path.dart';

class SongFile {
  String id;
  String filename;
  String format = "";
  bool availableOnOffline = true;
  Lyrics lyrics = Lyrics();
  int? startsAt;
  int? endsAt;
  String? canvasId;
  int? canvasStartsAt;
  int? canvasEndsAt;

  SongFile.fromMap(String songId, Map<String, dynamic> data)
      : id = data["id"],
        filename = data["filename"],
        format = data["format"] ?? "" {
    initLyrics(data["lyrics"]);

    availableOnOffline = File(songMediaFilePath(songId, filename)).existsSync();
  }

  SongFile({required this.id, required this.filename});

  static SongFile created({required String path, required File originalFile}) {
    var songInfoFilename = FilenameUtils.generatedFileName(".json", path);
    var songInfoFile = File(PathUtils.join(path, songInfoFilename));
    var songInfo = {"volume": 1.0};
    songInfoFile.writeAsStringSync(jsonEncode(songInfo));

    var songFilename = "${FilenameUtils.nameOnly(songInfoFilename)}.${FilenameUtils.extensionName(originalFile.path)}";
    var songFile = File(PathUtils.join(path, songFilename));
    songFile.writeAsBytesSync(originalFile.readAsBytesSync());

    var result = SongFile(id: "", filename: "");
    result.filename = FilenameUtils.nameOnly(songFilename);
    result.format = FilenameUtils.extensionName(songFile.path);
    return result;
  }

  void initLyrics(dynamic data) {
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is List<dynamic>) {
          for (var line in value) {
            if (line is Map<String, dynamic>) {
              lyrics.data.get("default").add(LyricLine(startsAt: line["startsAt"], endsAt: line["endsAt"], text: line["text"]));
            } else {
              lyrics.data.get("default").add(LyricLine(text: line.toString()));
            }
          }
        } else {
          lyrics.data.get("default").add(LyricLine(text: data.toString()));
        }
      });
    } else {
      lyrics.data.get("default").add(LyricLine(text: data.toString()));
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "filename": filename, "format": format, "lyrics": lyrics.toMap()};
  }
}
