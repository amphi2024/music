
import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  static final _instance = AppStorage();

  static AppStorage getInstance() => _instance;

  String get databasePath => PathUtils.join(selectedUser.storagePath, "music.db");
}