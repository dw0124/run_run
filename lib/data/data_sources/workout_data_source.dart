import 'package:flutter/services.dart';

abstract class WorkoutDataSource {
  Future<void> startWorkout();
  Future<void> pauseWorkout();
  Future<void> finishWorkout();
  Future<void> saveWorkout(Map<String, dynamic> workout);
}

class HealthKitWorkoutDataSource implements WorkoutDataSource {
  HealthKitWorkoutDataSource({
    MethodChannel methodChannel =
    const MethodChannel('com.example.runRun/workout_channel'),
  }) : _channel = methodChannel;

  final MethodChannel _channel;

  @override
  Future<void> saveWorkout(Map<String, dynamic> workout) async {
    await _channel.invokeMethod('workout', workout);
  }
  @override
  Future<void> startWorkout() async {
    await _channel.invokeMethod('start');
  }

  @override
  Future<void> pauseWorkout() async {
    await _channel.invokeMethod('pause');
  }

  @override
  Future<void> finishWorkout() async {
    await _channel.invokeMethod('finish');
  }

}