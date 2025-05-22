import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/models/app_storage.dart';

class Playlist {
  String path = "";
  String id = "";
  Map<String, dynamic> data = {
    "title": "",
    "songs": []
  };

  set title(value) => data["title"] = value;
  String get title => data["title"];

  List<dynamic> get songs => data["songs"];
  set songs(value) => data["songs"] = value;

  List<int> thumbnailData = [];

  static Playlist created() {
    var playlist = Playlist();
    var filename = FilenameUtils.generatedFileName(".playlist", appStorage.playlistsPath);
    playlist.path = PathUtils.join(appStorage.playlistsPath, filename);
    playlist.id = FilenameUtils.nameOnly(filename);
    return playlist;
  }

  static Playlist fromFile(File file) {
    try {
      var playlist = Playlist();
      playlist.id = FilenameUtils.nameOnly(PathUtils.basename(file.path));
      playlist.path = file.path;
      playlist.data = jsonDecode(file.readAsStringSync());

      if(playlist.songs.length > 3) {
        for (int i = 0; i < 4; i++) {
          int index = Random().nextInt(playlist.songs.length);
          if (playlist.thumbnailData.contains(index)) {
            i--;
          }
          else {
            playlist.thumbnailData.add(index);
          }
        }
      }
      return playlist;
    }
    catch(e) {
      return Playlist();
    }
  }

  void save({bool upload = true}) async {
    var file = File(path);
    await file.writeAsString(jsonEncode(data));

    if(upload) {
      appWebChannel.uploadPlaylist(playlist: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    var file = File(path);
    var directory = Directory(PathUtils.join(appStorage.playlistsPath, id));
    if(await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await file.delete();
    if(upload) {
      appWebChannel.deletePlaylist(id: id);
    }
  }

  void shuffle() {
    Random random = Random();
    songs.shuffle(random);
  }

  bool isNormalPlaylist() {
    return id != "" && !id.startsWith("!ALBUM") && !id.startsWith("!ARTIST") && !id.startsWith("!GENRE") && id != "!ARCHIVE";
  }
}