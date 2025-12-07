import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:amphi/utils/try_json_decode.dart';
import 'package:music/channels/app_web_channel.dart';
import 'package:music/database/database_helper.dart';
import 'package:music/utils/generated_id.dart';
import 'package:music/utils/json_value_extractor.dart';
import 'package:music/utils/media_file_path.dart';
import 'package:sqflite/sqflite.dart';

class Artist {
  String id;
  Map<String, dynamic> name;
  List<Member> members;
  List<Map<String, dynamic>> images;
  DateTime created;
  DateTime modified;
  DateTime? deleted;
  DateTime? debut;
  String? country;
  String? description;
  int imageIndex = 0;

  Artist({
    required this.id,
    this.name = const {},
    this.members = const [],
    this.images = const [],
    DateTime? created,
    DateTime? modified,
    this.deleted,
    this.debut,
    this.country,
    this.description,
  }) : created = created ?? DateTime.now(),
        modified = modified ?? DateTime.now();

  Artist.fromMap(Map<String, dynamic> data)
      : id = data["id"],
        name = tryJsonDecode(data["name"], defaultValue: {"default": data["name"].toString()}) as Map<String, dynamic>,
        members = data.getMapList("members").map((e) => Member.fromMap(e)).toList(),
        images = data.getMapList("images"),
        created = data.getDateTime("created"),
        modified = data.getDateTime("modified"),
        deleted = data.getNullableDateTime("deleted"),
        debut = data.getNullableDateTime("debut"),
        country = data["country"],
        description = data["description"] {
    imageIndex = Random().nextInt(images.length);
  }

  Future<void> save({bool upload = true}) async {
    if(id.isEmpty) {
      id = await generatedArtistId();
    }
    final database = await databaseHelper.database;
    await database.insert("artists", toSqlInsertMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    if(upload) {
      appWebChannel.uploadArtist(artist: this);
    }
  }

  Future<void> delete({bool upload = true}) async {
    if(id.isEmpty) {
      return;
    }

    final database = await databaseHelper.database;
    await database.delete("artists", where: "id = ?", whereArgs: [id]);

    final directory = Directory(mediaDirectoryPath(id, "artists"));
    await directory.delete(recursive: true);
    if(upload) {
      appWebChannel.deleteArtist(id: id);
    }
  }

  Map<String, dynamic> toSqlInsertMap() {
    return {
      "id": id,
      "name": jsonEncode(name),
      "members": jsonEncode(members.map((e) => e.toMap()).toList()),
      "images": jsonEncode(images),
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "debut": debut?.toUtc().millisecondsSinceEpoch,
      "country": country,
      "description": description
    };
  }

  Map<String, dynamic> toJsonBody() {
    return {
      "id": id,
      "name": name,
      "members": members.map((e) => e.toMap()).toList(),
      "images": images,
      "created": created.toUtc().millisecondsSinceEpoch,
      "modified": modified.toUtc().millisecondsSinceEpoch,
      "deleted": deleted?.toUtc().millisecondsSinceEpoch,
      "debut": debut?.toUtc().millisecondsSinceEpoch,
      "country": country,
      "description": description
    };
  }
}

class Member {
  String id;
  String? role;

  Member.fromMap(Map<String, dynamic> map) : id = map["id"], role = map["role"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "role": role
    };
  }
}