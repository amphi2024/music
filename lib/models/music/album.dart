import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/music/artist.dart';
import 'package:music/utils/random_alphabet.dart';

import '../app_storage.dart';

class Album {

  Map<String, dynamic> data = {
    "name": <String, dynamic>{},
    "genre": <String, dynamic>{},
    "artist": "",
    "added": DateTime.now().toUtc().millisecondsSinceEpoch,
    "modified": DateTime.now().toUtc().millisecondsSinceEpoch
  };

  Map<String, dynamic> get name => data["name"];
  Map<String, dynamic> get genre => data["genre"];
  Artist get artist => appStorage.artists[data["artist"]] ?? Artist();
  set artist(value) => data["artist"] = value;
  List<String> covers = [];
  List<String> music = [];
  DateTime get added => DateTime.fromMillisecondsSinceEpoch(data["added"], isUtc: true).toLocal();
  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"], isUtc: true).toLocal();
  late String id;
  late String path;

  static Album created({required Map metadata, required String artistId, required List<int> albumCover}) {
    var album = Album();
    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.albumsPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.albumsPath , alphabet , filename));
    directory.createSync(recursive: true);

    Directory(PathUtils.join(directory.path, "covers")).createSync();
    album.path = directory.path;
    album.id = filename;

    album.name["default"] = metadata["album"];
    album.genre["default"] = metadata["genre"];
    album.artist = artistId;

    if(albumCover.isNotEmpty) {
      var coverFilename = FilenameUtils.generatedFileName(".jpg", PathUtils.join(album.path, "covers"));
      var coverFile = File(PathUtils.join(album.path, "covers", coverFilename));
      coverFile.writeAsBytes(albumCover);
      album.covers.add(coverFile.path);
    }

    return album;
  }

  static Album fromDirectory(Directory directory) {
    Album album = Album();
    album.path = directory.path;
    album.id = PathUtils.basename(album.path);

    var coversDir = Directory(PathUtils.join(directory.path, "covers"));
    if(!coversDir.existsSync()) {
      coversDir.createSync();
    }
    for(var file in coversDir.listSync()) {
      album.covers.add(file.path);
    }
    var infoFile = File(PathUtils.join(album.path, "info.json"));
    if(infoFile.existsSync()) {
      album.data = jsonDecode(infoFile.readAsStringSync());
    }
    appStorage.songs.forEach((key, music) {
      if(music.albumId == album.id) {
        album.music.add(music.id);
      }
    });

    return album;
  }

  Future<void> save({bool upload = true}) async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));

    if(upload) {
      appWebChannel.uploadAlbumInfo(album: this);
      // for(var filePath in covers) {
      //
      // }
    }
  }
}