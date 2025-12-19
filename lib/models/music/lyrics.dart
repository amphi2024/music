import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music/models/app_settings.dart';

import 'lyrics/lrc.dart';
import 'lyrics/lrc_line.dart';

class Lyrics {
  Map<String, List<LyricLine>> data = {};

  void disposeTextControllers() {
    data.forEach((key, lines) {
      for(var line in lines) {
        line.disposeTextControllers();
      }
    });
  }

  List<LyricLine> getLinesByLocale(BuildContext context) {
    var localeCode = Localizations.localeOf(context).languageCode;
    return data[localeCode] ?? data["default"] ?? [];
  }

  List<LyricLine> getLocalizedLines() {
    return data[appSettings.localeCode ?? "default"] ?? [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    data.forEach((key, lines) {
      List<Map<String, dynamic>> list = [];
      for(var lyricLine in lines) {
        list.add(
            {
              "startsAt": lyricLine.startsAt,
              "endsAt": lyricLine.endsAt,
              "text": lyricLine.text
            }
        );
      }
      map[key] = list;
    });
    return map;
  }

  static Future<Lyrics?> fromSelectedFile(String localeCode) async {
    var result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["lrc"], allowMultiple: false);
    var selectedFiles = result?.files;
    if(selectedFiles != null) {
      var pFile = selectedFiles.firstOrNull;
      var filePath = pFile?.xFile.path;
      if(filePath != null) {
        return fromFile(File(filePath), localeCode);
      }
    }
    return null;
  }

  static Lyrics fromFile(File file, String localeCode) {
    Lyrics lyrics = Lyrics();

    var lrc = Lrc.fromFile(file);
    List<LyricLine> lines = [];
    for(int i = 0; i < lrc.lines.length; i++) {
      var line = lrc.lines[i];
      LrcLine? nextLine;
      if(i < lrc.lines.length - 1) {
        nextLine = lrc.lines[i + 1];
      }
      lines.add(LyricLine(
        startsAt: line.startsAt,
        endsAt: nextLine?.startsAt ?? (i == lrc.lines.length - 1 ? line.startsAt + 3000 : 0),
        text: line.text
      ));
      lyrics.data[localeCode] = lines;
    }
    return lyrics;
  }
}

class LyricLine {
  int startsAt = 0;
  int endsAt = 0;
  String text = "";
  TextEditingController? _startTimeController;
  TextEditingController? _endTimeController;
  TextEditingController? _lyricsTextController;

  void disposeTextControllers() {
    _startTimeController?.dispose();
    _endTimeController?.dispose();
    _lyricsTextController?.dispose();

    _startTimeController = null;
    _endTimeController = null;
    _lyricsTextController = null;
  }

  TextEditingController get startTimeController {
    if(_startTimeController != null) {
      return _startTimeController!;
    }
    else {
      _startTimeController = TextEditingController(text: convertMillisecondsToTimeString(startsAt));
      return _startTimeController!;
    }
  }

  TextEditingController get endTimeController {
    if(_endTimeController != null) {
      return _endTimeController!;
    }
    else {
      _endTimeController = TextEditingController(text: convertMillisecondsToTimeString(endsAt));
      return _endTimeController!;
    }
  }

  TextEditingController get lyricsTextController {
    if(_lyricsTextController != null) {
      return _lyricsTextController!;
    }
    else {
      _lyricsTextController = TextEditingController(text: text);
      return _lyricsTextController!;
    }
  }

  LyricLine({this.text = "", this.startsAt = 0, this.endsAt = 0});
}

String convertMillisecondsToTimeString(int totalMilliseconds) {
  // Calculate the hours, minutes, seconds, and milliseconds from the total milliseconds
  int hours = totalMilliseconds ~/ (3600 * 1000);
  int remainingMinutesAndSeconds = totalMilliseconds % (3600 * 1000);
  int minutes = remainingMinutesAndSeconds ~/ (60 * 1000);
  int remainingSeconds = remainingMinutesAndSeconds % (60 * 1000);
  int seconds = remainingSeconds ~/ 1000;
  int milliseconds = remainingSeconds % 1000;

  // Format the time as "HH:mm:ss.SSS"
  return '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}.${milliseconds.toString().padLeft(3, '0')}';
}

String _formatTime(int timeUnit) {
  return timeUnit.toString().padLeft(2, '0');
}

extension GetDataExtension on Map<String, List<LyricLine>> {
  List<LyricLine> get(String key) {
    return putIfAbsent(key, () => []);
  }
}