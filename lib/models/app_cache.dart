import 'package:amphi/models/app_cache_data_core.dart';

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

}