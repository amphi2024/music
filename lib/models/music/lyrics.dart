import 'package:flutter/material.dart';

class Lyrics {
  List<LyricLine> lines = [];

  void disposeTextControllers() {
    for(var line in lines) {
      line.disposeTextControllers();
    }
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
      _startTimeController = TextEditingController(text: "00:00.00");
      return _startTimeController!;
    }
  }

  TextEditingController get endTimeController {
    if(_endTimeController != null) {
      return _endTimeController!;
    }
    else {
      _endTimeController = TextEditingController(text: "00:00.00");
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
