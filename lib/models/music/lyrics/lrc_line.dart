class LrcLine {
  String text;
  int startsAt;

  LrcLine({
    required this.text,
    required this.startsAt
});

  static LrcLine? fromFileContent(String fileContent) {
    String text = "";
    int startsAt = 0;
    var split = fileContent.split("]");
    if(split.length >= 2) {
      var durationParsed = split[0].substring(1).split(":");
      var min = int.tryParse(durationParsed[0]);
      var seconds = double.tryParse(durationParsed[1]);
      if(min != null && seconds != null) {
        startsAt += min * 60 * 1000;
        startsAt += (seconds * 1000).round();
      }
      else {
        return null;
      }
      text = split[1];
      return LrcLine(text: text, startsAt: startsAt);
    }
    else {
      return null;
    }

  }

}