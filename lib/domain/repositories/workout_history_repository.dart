import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';
import 'package:run_run/shared/result.dart';

abstract class WorkoutHistoryRepository {
  Future<Result<List<WorkoutHistory>>> fetchWorkoutList({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<WorkoutDetailHistory>> fetchWorkoutDetails({
    required String workoutId,
  });
}
