import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/utils/path_utils.dart';

final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {

  late String themesPath;
  late String musicPath;

  static final _instance = AppStorage();
  static getInstance() => _instance;



  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");
    musicPath = PathUtils.join(selectedUser.storagePath, "music");
  }
}