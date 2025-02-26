import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../utils/random_alphabet.dart';
import '../app_storage.dart';
import 'album.dart';
import 'artist.dart';

class Music {

  Map<String, dynamic> data = {
    "title": <String, dynamic>{},
    "genre": <String, dynamic>{},
    "artist": "",
    "album": ""
  };

  Map<String, dynamic> get title => data["title"];
  Map<String, dynamic> get genre => data["genre"];
  set artist(value) => data["artist"] = value;
  Artist get artist => appStorage.artists[data["artist"]] ?? Artist();
  set album(value) => data["album"] = value;
  Album get album => appStorage.albums[data["album"]] ?? Album();
  String id = "";
  String path = "";
  List<String> files = [];

  static Music created({required Tag? tag,required String artistId, required String albumId, required File file}) {
    var music = Music();

    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.musicPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.musicPath , alphabet ,filename));
    directory.createSync(recursive: true);

    music.title["default"] = tag?.title ?? "unknown";
    music.id = filename;
    music.path = directory.path;
    music.artist = artistId;
    music.album = albumId;
    music.genre["default"] = tag?.genre ?? "unknown";

    var musicInfoFilename = FilenameUtils.generatedFileName(".json", directory.path);
    var musicInfoFile = File(PathUtils.join(directory.path, musicInfoFilename));
    var musicInfo = {
      "volume": 1.0
    };
    musicInfoFile.writeAsStringSync(jsonEncode(musicInfo));

    var musicFilename = "${FilenameUtils.nameOnly(musicInfoFilename)}.${FilenameUtils.extensionName(file.path)}";
    var musicFile = File(PathUtils.join(directory.path, musicFilename));
    musicFile.writeAsBytesSync(file.readAsBytesSync());

    return music;
  }

  static Music fromDirectory(Directory directory) {
    var music = Music();
    music.path = directory.path;
    music.id = PathUtils.basename(directory.path);
    var infoFile = File(PathUtils.join(music.path, "info.json"));
    music.data = jsonDecode(infoFile.readAsStringSync());

    return music;
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
  }
}