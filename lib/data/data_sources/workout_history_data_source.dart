import 'package:flutter/services.dart';
import 'package:run_run/data/errors/workout_history_exception.dart';
import 'package:run_run/shared/result.dart';

abstract class WorkoutHistoryDataSource {
  /// startDate ~ endDate 범위의 러닝 기록 목록 조회
  Future<Result<List<Map<String, dynamic>>>> fetchWorkoutList({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// workoutId에 해당하는 운동 상세 데이터 조회
  Future<Result<Map<String, dynamic>>> fetchWorkoutDetails({
    required String workoutId,
  });
}

class HealthKitWorkoutHistoryDataSource implements WorkoutHistoryDataSource {
  HealthKitWorkoutHistoryDataSource({
    MethodChannel methodChannel =
        const MethodChannel('com.example.runRun/workout_history_channel'),
  }) : _channel = methodChannel;

  final MethodChannel _channel;

  @override
  Future<Result<List<Map<String, dynamic>>>> fetchWorkoutList({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('fetchWorkoutList', {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      final workouts = (result ?? [])
          .cast<Map<Object?, Object?>>()
          .map((e) => e.cast<String, dynamic>())
          .toList();

      return Success(workouts);
    } on PlatformException catch (e) {
      return Failure(_mapException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchWorkoutDetails({
    required String workoutId,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'fetchWorkoutDetails',
        {'workoutId': workoutId},
      );

      return Success((result ?? {}).cast<String, dynamic>());
    } on PlatformException catch (e) {
      return Failure(_mapException(e));
    }
  }

  WorkoutHistoryException _mapException(PlatformException e) => switch (e.code) {
    'NOT_FOUND'     => const WorkoutNotFoundException(),
    'INVALID_DATE'  => const WorkoutInvalidDateException(),
    'INVALID_ARGS'  => const WorkoutInvalidArgsException(),
    _               => WorkoutFetchFailedException(e.message ?? e.code),
  };
}
