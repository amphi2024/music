import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/providers/songs_provider.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/json_value_extractor.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/media_file_path.dart';

class Playlist {
  String id;
  String title;
  List<String> songs = [];
  DateTime created = DateTime.now();
  DateTime modified = DateTime.now();
  DateTime? deleted;
  List<Map<String, dynamic>> thumbnails = [];
  String? note;

  Set<int> thumbnailIndexes = {};

  Playlist({
    required this.id,
    this.title = "",
  });

  Playlist.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        title = data["title"],
        songs = data.getStringList("songs"),
        created = data.getDateTime("created"),
        modified = data.getDateTime("modified"),
        deleted = data.getNullableDateTime("deleted"),
        thumbnails = data.getMapList("thumbnails"),
        note = data["note"] {
    initThumbnailIndexes();
  }

  void initThumbnailIndexes() {
    if(songs.length > 3) {
      while(thumbnailIndexes.length < 4) {
        final index = Random().nextInt(songs.length);
        thumbnailIndexes.add(index);
      }
    }
    else {
      thumbnailIndexes = {};
    }
  }

  Future<void> save({bool upload = true}) async {
    if (id.isEmpty) {
      id = await generatedPlaylistId();
    }
    final database = await databaseHelper.database;
    await database.insert("playlists", toSqlInsertMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    if (upload) {
      appWebChannel.uploadPlaylist(playlist: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    if (id.isEmpty) {
      return;
    }
    final database = await databaseHelper.database;
    await database.delete("playlists", where: "id = ?", whereArgs: [id]);

    final directory = Directory(mediaDirectoryPath(id, "playlists"));
    await directory.delete(recursive: true);
    if (upload) {
      appWebChannel.deletePlaylist(id: id);
    }
  }

  void sort(Ref ref) {
    songs.sortSongs(id, ref);
  }

  void shuffle() {
    Random random = Random();
    songs.shuffle(random);
  }

  bool isNormalPlaylist() {
    return id != "" && !id.startsWith("!ALBUM") && !id.startsWith("!ARTIST") && !id.startsWith("!GENRE") && id != "!ARCHIVE";
  }

  Map<String, dynamic> toSqlInsertMap() {
    return {
      "id": id,
      "title": title,
      "songs": jsonEncode(songs),
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "thumbnails": jsonEncode(thumbnails),
      "note": note
    };
  }

  Map<String, dynamic> toJsonBody() {
    return {
      "id": id,
      "title": title,
      "songs": songs,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "thumbnails": thumbnails,
      "note": note
    };
  }
}
