
import 'package:music/models/connected_device.dart';

final appState = AppState.getInstance();

class AppState {
  static final AppState _instance = AppState();
  static AppState getInstance() => _instance;

  int fragmentIndex = 0;
  bool playingBarExpanded = false;
  bool playingBarShowing = true;
  bool accountButtonExpanded = false;
  bool fragmentTitleMinimized = false;
  bool floatingMenuShowing = false;
  bool fragmentTitleShowing = true;
  bool autoScrollLyrics = true;

  List<String>? selectedSongs;
  String? showingPlaylistId;
  String? showingArtistId;
  String? showingAlbumId;
  String? showingGenre;

  Map<String, ConnectedDevice> connectedDevices = {};

  late void Function(void Function()) setState;

  late void Function(void Function()) setMainViewState;
  late void Function(void Function()) setFragmentState;
  void Function() requestScrollToTop = () {};
  void Function(void Function())? onConnectedDeviceUpdated;

}