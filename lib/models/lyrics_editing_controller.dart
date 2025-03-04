import 'package:music/models/music/lyrics.dart';
import 'package:music/models/music/song_file.dart';

class LyricsEditingController {
  Lyrics lyrics;
  String songFilePath;
  bool readOnly = true;

  LyricsEditingController({required this.lyrics, this.songFilePath = "", this.readOnly = true});
}