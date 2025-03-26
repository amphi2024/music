abstract class DurationConverter {
  static String _formatTime(int timeUnit) {
    return timeUnit.toString().padLeft(2, '0');
  }

  static String convertedDuration(int totalMilliseconds) {
    int hours = totalMilliseconds ~/ (3600 * 1000);
    int remainingMinutesAndSeconds = totalMilliseconds % (3600 * 1000);
    int minutes = remainingMinutesAndSeconds ~/ (60 * 1000);
    int remainingSeconds = remainingMinutesAndSeconds % (60 * 1000);
    int seconds = remainingSeconds ~/ 1000;

    if (hours == 0) {
      if (minutes == 0) {
        return '0:${_formatTime(seconds)}';
      }
      return '${_formatTime(minutes)}:${_formatTime(seconds)}';
    }
    return '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(seconds)}';
  }
}