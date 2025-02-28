final appState = AppState.getInstance();

class AppState {
  static final AppState _instance = AppState();
  static AppState getInstance() => _instance;

  int fragmentIndex = 0;
  bool playingBarExpanded = false;

  late void Function(void Function()) setState;

  late void Function(void Function()) setMainViewState;

}