import 'dart:math';

class Playlist {
  List<String> queue = [];
  String title = "";
  String path = "";
  String id = "";

  void shuffle() {
    Random random = Random();
    queue.shuffle(random);
  }
}