import 'package:amphi/models/app_cache_data_core.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:music/models/app_storage.dart';
import 'package:music/models/sort_option.dart';

final appCacheData = AppCacheData.getInstance();

class AppCacheData extends AppCacheDataCore {
    static final AppCacheData _instance = AppCacheData();
    static AppCacheData getInstance() => _instance;

    set lastPlayedPlaylistId(value) => data["lastPlayedPlaylistId"] = value;
    String get lastPlayedPlaylistId => data["lastPlayedPlaylistId"] ?? "";

    set lastPlayedSongId(String value) => data["lastPlayedSongId"] = value;
    String get lastPlayedSongId => data["lastPlayedSongId"] ?? "";

    set shuffled(bool value) => data["shuffled"] = value;
    bool get shuffled => data["shuffled"] ?? true;

    set playMode(int value) => data["playMode"] = value;
    int get playMode => data["playMode"] ?? 0;

    set uploadingFiles(value) => data["uploadingFiles"] = value;
    List<dynamic> get uploadingFiles => data.putIfAbsent("uploadingFiles", () => []);

    set volume(value) => data["volume"] = value;
    double get volume => data["volume"] ?? 0.5;

    String sortOption(String playlistId) {
        var dirName = PathUtils.basename(appStorage.selectedUser.storagePath);
        if(data["sortOption"]?[dirName] is Map) {
            var option = data["sortOption"][dirName][playlistId.isEmpty ? "!SONGS" : playlistId];
            if(option is String) {
                return option;
            }
            else {
                return SortOption.title;
            }
        }
        else {
            data["sortOption"] = <String, dynamic>{};
            return SortOption.title;
        }
    }

    void setSortOption({required String sortOption, required String playlistId}) {
        var dirName = PathUtils.basename(appStorage.selectedUser.storagePath);
        if(data["sortOption"]?[dirName] is! Map) {
            data["sortOption"] = <String, dynamic>{};
            data["sortOption"][dirName] = <String, dynamic>{};
        }
        data["sortOption"][dirName][playlistId] = sortOption;
    }

}