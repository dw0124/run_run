part of 'workout_bloc.dart';

sealed class WorkoutEvent {
  const WorkoutEvent();
}

final class WorkoutStartEvent extends WorkoutEvent {}
final class WorkoutPauseEvent extends WorkoutEvent {}
final class WorkoutFinishEvent extends WorkoutEvent {}
final class WorkoutCancelEvent extends WorkoutEvent {}

final class WorkoutSaveEvent extends WorkoutEvent {}

final class _WorkoutTickedEvent extends WorkoutEvent {}