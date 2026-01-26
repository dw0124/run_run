import 'package:run_run/domain/entities/location.dart';

class KalmanFilter {
  // 현재 추정값
  double? x;

  // 오차 공분산
  double p = 1.0;

  // 프로세스 노이즈 (시스템의 불확실성, 작을수록 추정값에 더 의존)
  double q = 0.005;

  // 측정 노이즈 (센서의 노이즈 수준, 작을수록 센서 값을 신뢰)
  double r = 0.01;

  // 칼만 게인 (업데이트 단계에서 사용)
  double k = 0.0;

  KalmanFilter();

  /// GPS 정확도와 속도 정보를 기반으로 R, Q를 조정한 후 필터를 업데이트
  double update({
    required double measurement,
    required double accuracy,
    required double speed,
  }) {
    if (x == null) {
      x = measurement;
      p = 1.0;
      return x!;
    }

    _updateR(accuracy);
    _updateQ(speed);

    // 예측 단계
    p = p + q;

    // 업데이트 단계
    k = p / (p + r);
    x = x! + k * (measurement - x!);
    p = (1 - k) * p;

    return x!;
  }

  /// GPS 수평 정확도(horizontalAccuracy)를 기준으로 R(측정 노이즈) 조정
  void _updateR(double accuracy) {
    if (accuracy < 5) {
      r = 0.01; // 매우 정확할 때
    } else if (accuracy < 10) {
      r = 0.05;
    } else {
      r = 0.1; // 정확도가 낮을 때
    }
  }

  /// 사용자 속도를 기준으로 Q(프로세스 노이즈) 조정
  void _updateQ(double speed) {
    if (speed < 1.0) {
      q = 0.005; // 정지 상태
    } else if (speed < 3.0) {
      q = 0.01; // 걷기
    } else if (speed < 6.0) {
      q = 0.02; // 조깅
    } else {
      q = 0.05; // 달리기 이상
    }
  }

  /// 정지 또는 종료시 상태 초기화를 위한 메서드
  void reset() {
    x = null;
    p = 1.0; // 다시 시작할 때는 불확실성을 높여서 GPS를 빠르게 따라가게 함
    k = 0.0;
  }
}