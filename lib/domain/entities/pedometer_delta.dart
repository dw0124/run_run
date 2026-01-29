class PedometerDelta {
  final String startDate;
  final String endDate;

  // 이번에 추가된 걸음 수 => 현재 누적 걸음수 - 이전 누적 걸음수
  final int stepDelta;

  // 이번에 추가된 거리(m) => 현재 누적 거리 - 이전 누적 거리
  // iOS - PedometerData의 distance는 optional이지만 null일 경우 0으로 처리
  final double distanceDelta;

  final double? currentPace;
  final double? currentCadence;

  PedometerDelta({
    required this.startDate,
    required this.endDate,
    required this.stepDelta,
    required this.distanceDelta,
    this.currentPace,
    this.currentCadence,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'stepDelta': stepDelta,
      'distanceDelta': distanceDelta,
      'currentPace': currentPace,
      'currentCadence': currentCadence,
    };
  }
}