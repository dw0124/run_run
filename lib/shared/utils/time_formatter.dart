class TimeFormatter {
  /// int(초)를 '00:00:00' 또는 '00:00' 형식으로 변환
  static String formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String h = hours.toString().padLeft(2, '0');
    final String m = minutes.toString().padLeft(2, '0');
    final String s = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return "$h:$m:$s";
    } else {
      return "$m:$s";
    }
  }
}