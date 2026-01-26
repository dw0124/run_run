part of 'workout_bloc.dart';

enum WorkoutStatus {
  initial,
  running,
  paused,
}

class WorkoutState extends Equatable {

  const WorkoutState({
    this.status = WorkoutStatus.initial,
    this.elapsedSeconds = 0,
  });

  final WorkoutStatus status;
  final int elapsedSeconds;

  WorkoutState copyWith({
    WorkoutStatus? status,
    int? elapsedSeconds,
  }) {
    return WorkoutState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  @override
  List<Object?> get props => [status, elapsedSeconds];
}