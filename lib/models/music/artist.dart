import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:audiotags/audiotags.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/music/album.dart';

class Artist {

  Map<String, String> name = {};
  List<Artist> members = [];
  late String id;
  Map<String, Album> albums = {};
  late String path;

  static Artist fromDirectory(Directory directory) {
    var artist = Artist();

    artist.path = directory.path;
    artist.id = PathUtils.basename(directory.path);


    return artist;
  }

  static Artist created(Tag? tag) {
    var artist = Artist();
    var filename = FilenameUtils.generatedDirectoryName(appStorage.artistsPath);
    var directory = Directory(PathUtils.join(appStorage.artistsPath , filename.substring(0, 1) ,filename));
    directory.createSync(recursive: true);
    artist.path = directory.path;
    artist.id = filename;
    artist.name["default"] = tag?.trackArtist ?? "";

    return artist;
  }

  Map<String, dynamic> toMap() {
    List<String> membersData = [];
    for(var member in members) {
      membersData.add(member.id);
    }
    return {
      "name": name,
      "members": membersData
    };
  }

  void save() async {
    var infoFile = File(PathUtils.join(path, "info.json"));
    await infoFile.writeAsString(jsonEncode(toMap()));
  }
}


