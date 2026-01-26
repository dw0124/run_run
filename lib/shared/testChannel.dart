import 'package:flutter/services.dart';

class TestChannel {
  // 앱의 고유한 채널 아이디를 설정합니다.
  static const MethodChannel _channel = MethodChannel('com.example.app/workout_test');

  // 0. 권한 요청
  Future<void> requestAuthorization() async {
    try {
      await _channel.invokeMethod('requestAuthorization');
      print('Workout Request Authorization 호출 성공');
    } on PlatformException catch (e) {
      print('실패: ${e.message}');
    }
  }

  // 1. 운동 시작
  Future<void> startWorkout() async {
    try {
      await _channel.invokeMethod('start');
      print('Workout Start 호출 성공');
    } on PlatformException catch (e) {
      print('실패: ${e.message}');
    }
  }

  // 2. 데이터 추가 (숫자 100 전달)
  Future<void> addSample({
    required double value,
    required String type, // 'step', 'distance', 'speed', 'energy' 등
  }) async {
    try {
      await _channel.invokeMethod('add', {
        'value': value,
        'type': type,
      });
      print('Data Add ($type: $value) 호출 성공');
    } on PlatformException catch (e) {
      print('실패: ${e.message}');
    }
  }

  // 3. 운동 종료
  Future<void> stopWorkout() async {
    try {
      await _channel.invokeMethod('stop');
      print('Workout Stop 호출 성공');
    } on PlatformException catch (e) {
      print('실패: ${e.message}');
    }
  }
}