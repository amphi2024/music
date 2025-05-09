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
    "title": <String, dynamic>{},
    "genre": <String, dynamic>{},
    "artist": "",
    "added": DateTime.now().toUtc().millisecondsSinceEpoch,
    "modified": DateTime.now().toUtc().millisecondsSinceEpoch
  };

  Map<String, dynamic> get title => data["title"];
  Map<String, dynamic> get genre => data["genre"];
  Artist get artist => appStorage.artists[data["artist"]] ?? Artist();
  String get artistId => data["artist"];
  set artist(value) => data["artist"] = value;
  List<String> covers = [];
  List<String> songs = [];
  DateTime get added => DateTime.fromMillisecondsSinceEpoch(data["added"], isUtc: true).toLocal();
  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"], isUtc: true).toLocal();
  String id = "";
  String path = "";

  static Album created({required Map metadata, required String artistId, required List<int> albumCover}) {
    var album = Album();
    String alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.albumsPath, alphabet);

    var directory = Directory(PathUtils.join(appStorage.albumsPath , alphabet , filename));

    album.path = directory.path;
    album.id = filename;

    album.title["default"] = metadata["album"];
    album.genre["default"] = metadata["genre"];
    album.artist = artistId;

    if(albumCover.isNotEmpty) {
      var coverFilename = FilenameUtils.generatedFileName(".jpg", album.path);
      var coverFile = File(PathUtils.join(album.path, coverFilename));
      directory.createSync(recursive: true);
      coverFile.writeAsBytes(albumCover);
      album.covers.add(coverFile.path);
    }

    return album;
  }

  static Album fromDirectory(Directory directory) {
    Album album = Album();
    album.path = directory.path;
    album.id = PathUtils.basename(album.path);

    for(var file in directory.listSync()) {
      if(!file.path.endsWith(".json")) {
        album.covers.add(file.path);
      }
    }
    var infoFile = File(PathUtils.join(album.path, "info.json"));
    if(infoFile.existsSync()) {
      album.data = jsonDecode(infoFile.readAsStringSync());
    }
    appStorage.songs.forEach((key, song) {
      if(song.albumId == album.id) {
        album.songs.add(song.id);
      }
    });

    return album;
  }

  Future<void> save({bool upload = true}) async {
    var directory = Directory(path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));

    if(upload) {
      appWebChannel.uploadAlbumInfo(album: this);
      appWebChannel.getAlbumCovers(id: id, onSuccess: (list) {

          for(var filePath in covers) {
            bool exists = false;
            for(var fileInfo in list) {
              var filename = PathUtils.basename(filePath);
              if (filename == fileInfo["filename"]) {
                exists = true;
                break;
              }
            }
            if(!exists) {
              appWebChannel.uploadAlbumCover(albumId: id, filePath: filePath);
            }
          }

      });

    }
  }

  Future<void> delete({bool upload = true}) async {
    var directory = Directory(path);
    await directory.delete(recursive: true);
    if(upload) {
      appWebChannel.deleteAlbum(id: id);
    }
  }

  Future<void> downloadMissingCovers() async {
    if(id.isNotEmpty) {
      appWebChannel.getAlbumCovers(id: id, onSuccess: (list) async {
        for (var coverInfo in list) {
          var filename = coverInfo["filename"];
          var file = File(PathUtils.join(path, filename));

          if (!await file.exists()) {
            appWebChannel.downloadAlbumCover(album: this, filename: filename);
            covers.add(file.path);
          }
        }
      });
    }
  }

  @override
  String toString() {
    return """
    id: ${id}
    artist: ${artist.toString()},
    title: ${title}
    """;
  }
}