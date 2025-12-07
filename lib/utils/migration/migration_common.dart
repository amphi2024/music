import 'dart:convert';
import 'dart:io';

import 'package:amphi/utils/path_utils.dart';

import '../../models/app_storage.dart';

Future<void> migrateDirectory(String id, String directoryName) async {
  var directory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, directoryName, id[0], id));
  var target = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "media", directoryName, id[0], id[1], id));
  if (await directory.exists() && id.length > 2 && !await target.exists()) {
    await Directory(PathUtils.join(appStorage.selectedUser.storagePath, "media", directoryName, id[0], id[1])).create(recursive: true);
    await directory.rename(target.path);
  }
}

String parsedLegacyListValue(Map<String, dynamic> map, String key) {
  final value = map[key];
  if(value != null) {
    return jsonEncode([value]);
  }
  return jsonEncode([]);
}