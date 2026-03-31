part of 'workout_history_bloc.dart';

sealed class WorkoutHistoryEvent {
  const WorkoutHistoryEvent();
}

final class WorkoutHistoryLoadEvent extends WorkoutHistoryEvent {
  const WorkoutHistoryLoadEvent({required this.period});
  final WorkoutPeriod period;
}

final class WorkoutHistoryFetchDetailsEvent extends WorkoutHistoryEvent {
  const WorkoutHistoryFetchDetailsEvent({required this.workoutId});
  final String workoutId;
}
