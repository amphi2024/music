import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/utils/random_alphabet.dart';

class Artist {

  Map<String, dynamic> data = {
    "name": <String, dynamic>{},
    "albums": <String>[],
    "members": <String>[],
    "added": DateTime.now().toUtc().millisecondsSinceEpoch,
    "modified": DateTime.now().toUtc().millisecondsSinceEpoch
  };
  Map<String, dynamic> get name => data["name"];
  List<dynamic> get albums => data["albums"];
  List<dynamic> get members => data["members"];
  DateTime get added => DateTime.fromMillisecondsSinceEpoch(data["added"], isUtc: true).toLocal();
  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"], isUtc: true).toLocal();
  List<String> profileImages = [];
  String id = "";

  String path = "";

  void refreshAlbums() {
    albums.clear();
    appStorage.albums.forEach((key, album) {
      if(id == album.artistId) {
        albums.add(album.id);
      }
    });
  }

  static Artist fromDirectory(Directory directory) {
    var artist = Artist();

    artist.path = directory.path;
    artist.id = PathUtils.basename(directory.path);
    var infoFile = File(PathUtils.join(artist.path, "info.json"));
    if(infoFile.existsSync()) {
      artist.data = jsonDecode(infoFile.readAsStringSync());
    }

    artist.albums.clear();

    appStorage.albums.forEach((key, album) {
      if(artist.id == album.artistId) {
        artist.albums.add(album.id);
      }
    });

    for(var file in directory.listSync()) {
      if(!file.path.endsWith("info.json")) {
        artist.profileImages.add(file.path);
      }
    }
    return artist;
  }

  static Artist created(Map metadata) {
    var artist = Artist();
    var alphabet = randomAlphabet();
    var filename = FilenameUtils.generatedDirectoryNameWithChar(appStorage.artistsPath, alphabet);
    var directory = Directory(PathUtils.join(appStorage.artistsPath , alphabet ,filename));
    artist.path = directory.path;
    artist.id = filename;
    artist.name["default"] = metadata["artist"];

    return artist;
  }

  Future<void> save({bool upload = true, List<PlatformFile>? selectedCoverFiles}) async {
    var directory = Directory(path);
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    }
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(data));

    if(selectedCoverFiles != null) {
      for(var selectedCover in selectedCoverFiles) {
        var filename = FilenameUtils.generatedFileName(".${selectedCover.extension!}", path);
        var file = File(PathUtils.join(path, filename));
        var bytes = await selectedCover.xFile.readAsBytes();
        await file.writeAsBytes(bytes);
        profileImages.add(file.path);
        appWebChannel.uploadArtistFile(id: id, filePath: file.path);
      }
    }

    if(upload) {
      appWebChannel.uploadArtistInfo(artist: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    var directory = Directory(path);
    await directory.delete(recursive: true);
    if(upload) {
      appWebChannel.deleteArtist(id: id);
    }
  }

  Future<void> downloadMissingFiles() async {
    appWebChannel.getArtistFiles(id: id, onSuccess: (files) async {
      for(var fileInfo in files) {
        var filename = fileInfo["filename"];
        var file = File(PathUtils.join(path, filename));
        if(!await file.exists()) {
          appWebChannel.downloadArtistFile(artist: this, filename: filename);
          profileImages.add(file.path);
        }
      }
    });
  }

  @override
  String toString() {
    return """
    id: ${id}
    name: ${name}
    """;
  }
}


