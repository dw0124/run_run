sealed class WorkoutHistoryFailure implements Exception {
  const WorkoutHistoryFailure();
}

class WorkoutHistoryNotFoundFailure extends WorkoutHistoryFailure {
  const WorkoutHistoryNotFoundFailure();
}

class WorkoutHistoryInvalidDateFailure extends WorkoutHistoryFailure {
  const WorkoutHistoryInvalidDateFailure();
}

class WorkoutHistoryInvalidArgsFailure extends WorkoutHistoryFailure {
  const WorkoutHistoryInvalidArgsFailure();
}

class WorkoutHistoryFetchFailedFailure extends WorkoutHistoryFailure {
  final String debugMessage;
  const WorkoutHistoryFetchFailedFailure(this.debugMessage);
}
