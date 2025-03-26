import 'package:music/models/music/lyrics.dart';

class LyricsEditingController {
  Lyrics lyrics;
  String songFilePath;
  bool readOnly = true;

  LyricsEditingController({required this.lyrics, this.songFilePath = "", this.readOnly = true});
}