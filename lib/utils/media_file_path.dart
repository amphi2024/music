import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';

String mediaDirectoryPath(String id, String directoryName) {
  return PathUtils.join(appStorage.selectedUser.storagePath, "media", directoryName, id[0], id[1], id);
}

String mediaFilePath(String id, String filename, String directoryName) {
  return PathUtils.join(appStorage.selectedUser.storagePath, "media", directoryName, id[0], id[1], id, filename);
}

String albumCoverPath(String id, String filename) => mediaFilePath(id, filename, "albums");

String songMediaFilePath(String id, String filename) => mediaFilePath(id, filename, "songs");

String artistImagePath(String id, String filename) => mediaFilePath(id, filename, "artists");

String playlistThumbnailPath(String id, String filename) => mediaFilePath(id, filename, "thumbnails");