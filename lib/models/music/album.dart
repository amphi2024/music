import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:music/channels/app_web_channel.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/json_value_extractor.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:sqflite/sqflite.dart';

class Album {
  String id;
  Map<String, dynamic> title;
  List<Map<String, dynamic>> genres;
  List<String> artistIds;
  List<Map<String, dynamic>> covers;
  DateTime created;
  DateTime modified;
  DateTime? deleted;
  DateTime? released;
  String? description;

  int? coverIndex;

  Album(
      {required this.id,
      this.title = const {},
      this.genres = const [],
      this.artistIds = const [],
      this.covers = const [],
      DateTime? created,
      DateTime? modified,
      this.deleted,
      this.released,
      this.description})
      : created = created ?? DateTime.now(),
        modified = modified ?? DateTime.now();

  Album.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        title = data.getMap("title"),
        covers = data.getMapList("covers"),
        genres = data.getMapList("genres"),
        artistIds = data.getStringList("artist_ids"),
        created = data.getDateTime("created"),
        modified = data.getDateTime("modified"),
        deleted = data.getNullableDateTime("deleted"),
        released = data.getNullableDateTime("released"),
        description = data["description"] {
    if(covers.isNotEmpty) {
      coverIndex = Random().nextInt(covers.length);
    }
  }

  Future<void> save({bool upload = true}) async {
    if (id.isEmpty) {
      id = await generatedAlbumId();
    }

    final database = await databaseHelper.database;
    await database.insert("albums", toSqlInsertMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    if (upload) {
      appWebChannel.uploadAlbum(album: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    if (id.isEmpty) {
      return;
    }
    final database = await databaseHelper.database;
    await database.delete("albums", where: "id = ?", whereArgs: [id]);

    final directory = Directory(mediaDirectoryPath(id, "albums"));
    await directory.delete(recursive: true);
    if (upload) {
      appWebChannel.deleteAlbum(id: id);
    }
  }

  Map<String, dynamic> toSqlInsertMap() {
    return {
      "id": id,
      "title": jsonEncode(title),
      "genres": jsonEncode(genres),
      "artist_ids": jsonEncode(artistIds),
      "covers": jsonEncode(covers),
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "released": released?.toUtc().millisecondsSinceEpoch,
      "description": description
    };
  }

  Map<String, dynamic> toJsonBody() {
    return {
      "id": id,
      "title": title,
      "genres": genres,
      "artist_ids": artistIds,
      "covers": covers,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "released": released?.toUtc().millisecondsSinceEpoch,
      "description": description
    };
  }
}
