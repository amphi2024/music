import 'dart:io';

import 'package:music/models/music/lyrics/lrc_line.dart';

class Lrc {

  List<LrcLine> lines = [];

  static Lrc fromFile(File file) {
    var lrc = Lrc();
    var fileContentLines = file.readAsStringSync().split("\n");
    for(int i = 0; i < fileContentLines.length; i++) {
      var line = LrcLine.fromFileContent(fileContentLines[i]);
      if(line != null) {
        lrc.lines.add(line);
      }
    }

    return lrc;
  }
}