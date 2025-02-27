import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';
import 'package:music/utils/random_alphabet.dart';

class Artist {

  Map<String, dynamic> data = {
    "name": <String, dynamic>{},
    "albums": <String>[],
    "members": <String>[]
  };
  Map<String, dynamic> get name => data["name"];
  List<dynamic> get albums => data["albums"];
  List<dynamic> get members => data["members"];
  late String id;

  late String path;

  static Artist fromDirectory(Directory directory) {
    var artist = Artist();

    artist.path = directory.path;
    artist.id = PathUtils.basename(directory.path);
    var infoFile = File(PathUtils.join(artist.path, "info.json"));
    artist.data = jsonDecode(infoFile.readAsStringSync());

    return artist;
  }

  static Artist created(Tag? tag) {
    var artist = Artist();
    var alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.artistsPath, alphabet);
    var directory = Directory(PathUtils.join(appStorage.artistsPath , alphabet ,filename));
    directory.createSync(recursive: true);
    artist.path = directory.path;
    artist.id = filename;
    artist.name["default"] = tag?.trackArtist ?? "";

    return artist;
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
  }
}


