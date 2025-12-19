import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';
import 'package:sqflite/sqflite.dart';

import 'migration_common.dart';

Future<void> migrateArtists(Database db) async {
  final batch = db.batch();
    var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "artists"));
  if(!await directory.exists()) {
    return;
  }
    for (var subDirectory in directory.listSync()) {
      if (subDirectory is Directory) {
        for (var artistDirectory in subDirectory.listSync()) {
          if (artistDirectory is Directory) {
            var artistId = PathUtils.basename(artistDirectory.path);
            var infoFile = File(PathUtils.join(artistDirectory.path, "info.json"));
            if (infoFile.existsSync()) {
              Map<String, dynamic> map = jsonDecode(await infoFile.readAsString());
              List<Map<String, dynamic>> images = [];
              for(var file in artistDirectory.listSync()) {
                if(!file.path.endsWith(".json")) {
                  images.add({
                    "id": PathUtils.basenameWithoutExtension(file.path),
                    "filename": PathUtils.basename(file.path)
                  });
                }
              }

              var data = _parsedLegacyArtist(artistId, map, images);
              batch.insert("artists", data);

              await migrateDirectory(artistId, "artists");
            }
          }
        }
      }
    }
  await batch.commit();
}

Map<String, dynamic> _parsedLegacyArtist(String id, Map<String, dynamic> map, List<Map<String, dynamic>> images) {
  return {
    "id": id,
    "name": jsonEncode(map["name"] ?? {}),
    "images": jsonEncode(images),
    "created": map["added"] ?? 0,
    "modified": map["modified"] ?? 0
  };
}