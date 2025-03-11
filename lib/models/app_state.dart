import 'package:music/models/music/song.dart';

final appState = AppState.getInstance();

class AppState {
  static final AppState _instance = AppState();
  static AppState getInstance() => _instance;

  int fragmentIndex = 0;
  bool playingBarExpanded = false;
  bool playingBarShowing = true;
  bool accountButtonExpanded = false;
  bool fragmentTitleMinimized = false;

  List<String>? selectedSongs;

  late void Function(void Function()) setState;

  late void Function(void Function()) setMainViewState;
  void Function() requestScrollToTop = () {};

}