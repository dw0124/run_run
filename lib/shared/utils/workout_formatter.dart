class WorkoutFormatter {
  // 거리 포맷 (m -> km)
  static String formatDistance(double meters) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  // 평균 페이스 계산
  static String formatAveragePace(int totalSeconds, double totalMeters) {
    if (totalMeters <= 0 || totalSeconds <= 0) return "-'--\"";
    final double secondsPerKm = totalSeconds / (totalMeters / 1000);
    return _formatPaceFromSeconds(secondsPerKm);
  }

  // 현재 페이스 계산
  static String formatCurrentPace(double? secondsPerMeter) {
    //print("formatCurrentPace $secondsPerMeter");

    if (secondsPerMeter == null || secondsPerMeter <= 0) return "-'--\"";
    final double secondsPerKm = secondsPerMeter * 1000;
    return _formatPaceFromSeconds(secondsPerKm);
  }

  // 내부 공통 포맷팅 로직
  static String _formatPaceFromSeconds(double secondsPerKm) {
    final int minutes = secondsPerKm ~/ 60;
    final int seconds = (secondsPerKm % 60).round();

    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  // 현재 케이던스 계산 (초당 걸음수 -> 분당 걸음수)
  static String formatCurrentCadence(double? stepsPerSecond) {
    if (stepsPerSecond == null || stepsPerSecond <= 0) return '-- spm';

    // 초당 걸음 수를 분당 걸음 수로 변환
    final spm = (stepsPerSecond * 60).round();

    return '$spm spm';
  }
}