import 'package:run_run/data/data_sources/workout_history_data_source.dart';
import 'package:run_run/data/errors/workout_history_exception.dart';
import 'package:run_run/data/errors/workout_history_exception_mapper.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';
import 'package:run_run/domain/repositories/workout_history_repository.dart';
import 'package:run_run/shared/result.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  final WorkoutHistoryDataSource _dataSource;

  WorkoutHistoryRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<WorkoutHistory>>> fetchWorkoutList({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _dataSource.fetchWorkoutList(
      startDate: startDate,
      endDate: endDate,
    );

    return switch (result) {
      Success(:final value) => Success(value.map((e) => e.toWorkoutHistory()).toList()),
      Failure(:final failure) => Failure((failure as WorkoutHistoryException).toFailure()),
    };
  }

  @override
  Future<Result<WorkoutDetailHistory>> fetchWorkoutDetails({
    required String workoutId,
  }) async {
    final result = await _dataSource.fetchWorkoutDetails(workoutId: workoutId);

    return switch (result) {
      Success(:final value) => Success(value.toWorkoutDetailHistory(workoutId)),
      Failure(:final failure) => Failure((failure as WorkoutHistoryException).toFailure()),
    };
  }
}
