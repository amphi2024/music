import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';

class MusicFile {
  String infoFilePath = "";
  String musicFilePath = "";

  String get id => FilenameUtils.nameOnly(infoFilePath!);

  MusicFile({
    this.infoFilePath = "",
    this.musicFilePath = ""
  });

  static MusicFile created({required String path, required File originalFile}) {
    var musicInfoFilename = FilenameUtils.generatedFileName(".json", path);
    var musicInfoFile = File(PathUtils.join(path, musicInfoFilename));
    var musicInfo = {
      "volume": 1.0
    };
    musicInfoFile.writeAsStringSync(jsonEncode(musicInfo));

    var musicFilename = "${FilenameUtils.nameOnly(musicInfoFilename)}.${FilenameUtils.extensionName(originalFile.path)}";
    var musicFile = File(PathUtils.join(path, musicFilename));
    musicFile.writeAsBytesSync(originalFile.readAsBytesSync());

    return MusicFile(
      infoFilePath: musicInfoFile.path,
      musicFilePath: musicFile.path
    );
  }
}