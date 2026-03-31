import 'package:flutter/services.dart';
import 'package:run_run/data/errors/workout_history_exception.dart';
import 'package:run_run/domain/errors/workout_history_failure.dart';

extension PlatformExceptionToWorkoutHistoryMapper on PlatformException {
  WorkoutHistoryException toWorkoutHistoryException() => switch (code) {
    'NOT_FOUND'    => const WorkoutNotFoundException(),
    'INVALID_DATE' => const WorkoutInvalidDateException(),
    'INVALID_ARGS' => const WorkoutInvalidArgsException(),
    _              => WorkoutFetchFailedException(message ?? code),
  };
}

extension WorkoutHistoryExceptionMapper on WorkoutHistoryException {
  WorkoutHistoryFailure toFailure() => switch (this) {
    WorkoutNotFoundException() => const WorkoutHistoryNotFoundFailure(),
    WorkoutInvalidDateException() => const WorkoutHistoryInvalidDateFailure(),
    WorkoutInvalidArgsException() => const WorkoutHistoryInvalidArgsFailure(),
    WorkoutFetchFailedException(:final debugMessage) =>
      WorkoutHistoryFetchFailedFailure(debugMessage),
  };
}
