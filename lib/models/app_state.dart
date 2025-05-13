
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

  List<String>? selectedSongs;

  late void Function(void Function()) setState;

  late void Function(void Function()) setMainViewState;
  late void Function(void Function()) setFragmentState;
  void Function() requestScrollToTop = () {};

}