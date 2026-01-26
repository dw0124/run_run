import 'package:flutter/services.dart';

abstract class WorkoutDataSource {
  Future<void> saveWorkout(Map<String, dynamic> workout);
}

class HealthKitWorkoutDataSource implements WorkoutDataSource {

  final MethodChannel _channel = MethodChannel('com.example.runRun/workout_channel');

  @override
  Future<void> saveWorkout(Map<String, dynamic> workout) async {
    await _channel.invokeMethod('workout', workout);
  }
}