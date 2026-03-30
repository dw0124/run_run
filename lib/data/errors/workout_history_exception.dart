sealed class WorkoutHistoryException implements Exception {
  final String debugMessage;
  const WorkoutHistoryException(this.debugMessage);
}

class WorkoutNotFoundException extends WorkoutHistoryException {
  const WorkoutNotFoundException() : super('NOT_FOUND');
}

class WorkoutInvalidDateException extends WorkoutHistoryException {
  const WorkoutInvalidDateException() : super('INVALID_DATE');
}

class WorkoutInvalidArgsException extends WorkoutHistoryException {
  const WorkoutInvalidArgsException() : super('INVALID_ARGS');
}

class WorkoutFetchFailedException extends WorkoutHistoryException {
  const WorkoutFetchFailedException(super.debugMessage);
}
