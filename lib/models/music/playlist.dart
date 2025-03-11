import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';

class Playlist {
  List<String> queue = [];
  String title = "";
  String path = "";
  String id = "";

  static Playlist created(String title) {
    var playlist = Playlist();
    var filename = FilenameUtils.generatedFileName(".playlist", appStorage.playlistsPath);
    playlist.path = PathUtils.join(appStorage.playlistsPath, filename);
    playlist.id = FilenameUtils.nameOnly(filename);
    playlist.title = title;
    return playlist;
  }

  static Playlist fromMap(Map<String, dynamic> map) {
    var playlist = Playlist();
    playlist.title = map["title"] ?? "";
    for(var songId in map["songs"]) {
      playlist.queue.add(songId);
    }

    return playlist;
  }

  static Playlist fromFile(File file) {
    try {
      var playlist = fromMap(jsonDecode(file.readAsStringSync()));
      playlist.id = FilenameUtils.nameOnly(PathUtils.basename(file.path));
      playlist.path = file.path;
      return playlist;
    }
    catch(e) {
      return Playlist();
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["title"] = title;
    List<String> songs = [];
    for(var songId in queue) {
      songs.add(songId);
    }
    map["songs"] = songs;
    return map;
  }

  void save() async {
    var file = File(path);
    await file.writeAsString(jsonEncode(toMap()));
  }

  void shuffle() {
    Random random = Random();
    queue.shuffle(random);
  }
}