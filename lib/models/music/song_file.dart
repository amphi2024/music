import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/music/lyrics.dart';

class SongFile {
  String infoFilePath = "";
  String songFilePath = "";
  Lyrics lyrics = Lyrics();

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
}