import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';
import 'package:sqflite/sqflite.dart';

Future<void> migratePlaylists(Database db) async {
  final batch = db.batch();
  final directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "playlists"));
  if(!await directory.exists()) {
    return;
  }
    for (var file in directory.listSync()) {
      if (file is File) {
        final map = jsonDecode(await file.readAsString());
        final id = FilenameUtils.nameOnly(PathUtils.basename(file.path));
        final data = _parsedLegacyPlaylist(id, map);
        batch.insert("playlists", data);
      }
    }

    await batch.commit();
}
Map<String, dynamic> _parsedLegacyPlaylist(String id, Map<String, dynamic> map) {
  return {
    "id": id,
    "title": map["title"] ?? "",
    "songs": jsonEncode(map["songs"] ?? []),
    "created": map["created"] ?? 0,
    "modified": map["modified"] ?? 0
  };
}