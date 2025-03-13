import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music/models/music/song_file.dart';
import 'package:music/ui/components/album_cover.dart';

import '../../utils/random_alphabet.dart';
import '../app_storage.dart';
import 'album.dart';
import 'artist.dart';

class Song {

  Map<String, dynamic> data = {
    "title": <String, dynamic>{},
    "genre": <String, dynamic>{},
    "artist": "",
    "album": "",
    "added": DateTime.now().toUtc().millisecondsSinceEpoch,
    "modified": DateTime.now().toUtc().millisecondsSinceEpoch,
    "composer": "",
    "released": DateTime.now().toUtc().millisecondsSinceEpoch
  };

  Map<String, dynamic> get title => data["title"];
  Map<String, dynamic> get genre => data["genre"];
  set artist(value) => data["artist"] = value;
  Artist get artist => appStorage.artists[data["artist"]] ?? Artist();
  String get artistId => data["artist"];
  String get albumId => data["album"];
  set album(value) => data["album"] = value;
  Album get album => appStorage.albums[data["album"]] ?? Album();
  String id = "";
  String path = "";
  DateTime get added => DateTime.fromMillisecondsSinceEpoch(data["added"], isUtc: true).toLocal();
  set added(DateTime value) => data["added"] = value.toUtc().millisecondsSinceEpoch;
  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"], isUtc: true).toLocal();
  set modified(DateTime value) => data["modified"] = value.toUtc().millisecondsSinceEpoch;
  DateTime get released => DateTime.fromMillisecondsSinceEpoch(data["released"], isUtc: true).toLocal();
  set released(DateTime value) => data["released"] = value.toUtc().millisecondsSinceEpoch;
  Artist get composer => appStorage.artists[data["composer"]] ?? Artist();
  String get composerId => data["composer"];
  Map<String, SongFile> files = {};
  String? songFilePath() {
    var path = files.entries.firstOrNull?.value.songFilePath;
    if(path != null && File(path).existsSync()) {
      return path;
    }
    else {
      return null;
    }
  }

  SongFile playingFile() {
    return files.entries.firstOrNull?.value ?? SongFile();
  }

  static Song created({required Map metadata, required String artistId, required String albumId, required File file}) {
    var song = Song();

    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.songsPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.songsPath , alphabet ,filename));
    directory.createSync(recursive: true);

    song.title["default"] = metadata["title"];
    song.id = filename;
    song.path = directory.path;
    song.artist = artistId;
    song.album = albumId;
    song.genre["default"] = metadata["genre"];

    var songFile = SongFile.created(path: directory.path, originalFile: file);
    song.files[songFile.id] = songFile;

    var releasedYear = metadata["year"];

    if(releasedYear != null && releasedYear is int) {
      song.released = DateTime(releasedYear);
    }

    return song;
  }

  static Song fromDirectory(Directory directory) {
    var song = Song();
    song.path = directory.path;
    song.id = PathUtils.basename(directory.path);
    var infoFile = File(PathUtils.join(song.path, "info.json"));
    song.data = jsonDecode(infoFile.readAsStringSync());

    for(var file in directory.listSync()) {
      var nameOnly = FilenameUtils.nameOnly(PathUtils.basename(file.path));
      if(nameOnly != "info") {
        if(FilenameUtils.extensionName(file.path) == "json") {
          var songFile = song.files.putIfAbsent(nameOnly, () => SongFile());
          songFile.infoFilePath = file.path;
          songFile.getData();
        }
        else {
          var songFile = song.files.putIfAbsent(nameOnly, () => SongFile());
          songFile.songFilePath = file.path;
        }
      }
    }

    return song;
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));
  }
}

extension MusicTitleExtension on Map<String, dynamic> {
  String byLocale(BuildContext context) {
    String value = this[Localizations.localeOf(context).languageCode] ?? putIfAbsent("default", () => "");
    if(value.isNotEmpty) {
      return value;
    }
    else {
      return "Unknown";
    }
  }
}