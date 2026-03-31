import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';
import 'package:run_run/domain/repositories/workout_history_repository.dart';
import 'package:run_run/shared/result.dart';

class FetchWorkoutHistoryListUseCase {
  final WorkoutHistoryRepository _repository;

  FetchWorkoutHistoryListUseCase(this._repository);

  Future<Result<List<WorkoutHistory>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.fetchWorkoutList(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class FetchWorkoutHistoryDetailsUseCase {
  final WorkoutHistoryRepository _repository;

  FetchWorkoutHistoryDetailsUseCase(this._repository);

  Future<Result<WorkoutDetailHistory>> call({required String workoutId}) {
    return _repository.fetchWorkoutDetails(workoutId: workoutId);
  }
}
