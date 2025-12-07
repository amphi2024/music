import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/file_name_utils.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';
import 'package:sqflite/sqflite.dart';

import 'migration_common.dart';

Future<void> migrateSongs(Database db) async {
  final batch = db.batch();
  var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "songs"));
  for (var subDirectory in directory.listSync()) {
    if (subDirectory is Directory) {
      for (var songDirectory in subDirectory.listSync()) {
        if (songDirectory is Directory) {
          var songId = PathUtils.basename(songDirectory.path);
          var infoFile = File(PathUtils.join(songDirectory.path, "info.json"));
          if (infoFile.existsSync()) {
            Map<String, dynamic> map = jsonDecode(await infoFile.readAsString());
            List<Map<String, dynamic>> files = [];

            for (var songFile in songDirectory.listSync()) {
              var songFileId = FilenameUtils.nameOnly(PathUtils.basename(songFile.path));
              if (songFileId != "info" && songFile is File) {
                if (FilenameUtils.extensionName(songFile.path) == "json") {
                  var songFileMap = jsonDecode(await songFile.readAsString());
                  files.add({
                    "id": songFileId,
                    "filename": "$songFileId.${songFileMap["format"]}",
                    "format": songFileMap["format"],
                    "lyrics": songFileMap["lyrics"]
                  });
                }
                else { // .mp3, .flac, ...
                  final songFileInfo = File(PathUtils.join(appStorage.selectedUser.storagePath, "songs", songId[0], songId, "${songFileId}.json"));
                  if(!await songFileInfo.exists()) {
                    files.add({
                      "id": songFileId,
                      "filename": PathUtils.basename(songFile.path)
                    });
                  }
                }
              }
            }

            var data = _parsedLegacySong(songId, map, files);
            batch.insert("songs", data);

            await migrateDirectory(songId, "songs");
          }
        }
      }
    }
  }

  await batch.commit();
}

Map<String, dynamic> _parsedLegacySong(String id, Map<String, dynamic> map, List<Map<String, dynamic>> files) {
  return {
    "id": id,
    "title": jsonEncode(map["title"] ?? {}),
    "genres": parsedLegacyListValue(map, "genre"),
    "artist_ids": parsedLegacyListValue(map, "artist"),
    "album_id": map["album"],
    "created": map["added"],
    "modified": map["modified"],
    "deleted": null,
    "composer_ids": parsedLegacyListValue(map, "composer"),
    "lyricist_ids": parsedLegacyListValue(map, "lyricist"),
    "arranger_ids": parsedLegacyListValue(map, "arranger"),
    "producer_ids": parsedLegacyListValue(map, "producer"),
    "archived": map["archived"] == true ? 1 : 0,
    "released": map["released"],
    "track_number": map["trackNumber"],
    "disc_number": map["discNumber"],
    "files": jsonEncode(files)
  };
}
