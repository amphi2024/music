import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';
import 'package:sqflite/sqflite.dart';

import 'migration_common.dart';

Future<void> migrateAlbums(Database db) async {
  final batch = db.batch();
  var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "albums"));
  if(!await directory.exists()) {
    return;
  }
  for (var subDirectory in directory.listSync()) {
    if (subDirectory is Directory) {
      for (var albumDirectory in subDirectory.listSync()) {
        if (albumDirectory is Directory) {
          var albumId = PathUtils.basename(albumDirectory.path);
          var infoFile = File(PathUtils.join(albumDirectory.path, "info.json"));
          if (infoFile.existsSync()) {
            Map<String, dynamic> map = jsonDecode(await infoFile.readAsString());
            List<Map<String, dynamic>> covers = [];
            for(var file in albumDirectory.listSync()) {
              if(!file.path.endsWith(".json")) {
                covers.add({
                  "id": PathUtils.basenameWithoutExtension(file.path),
                  "filename": PathUtils.basename(file.path)
                });
              }
            }

            var data = _parsedLegacyAlbum(albumId, map, covers);
            batch.insert("albums", data);

            await migrateDirectory(albumId, "albums");
          }
        }
      }
    }
  }

  await batch.commit();
}

Map<String, dynamic> _parsedLegacyAlbum(String id, Map<String, dynamic> map, List<Map<String, dynamic>> covers) {
  return {
    "id": id,
    "title": jsonEncode(map["title"] ?? {}),
    "covers": jsonEncode(covers),
    "genres": jsonEncode([map["genre"] ?? {}]),
    "artist_ids": parsedLegacyListValue(map, "artist"),
    "created": map["added"] ?? map["created"] ?? 0,
    "modified": map["modified"] ?? 0,
    "deleted": null,
    "released": map["released"],
    "description": null
  };
}
