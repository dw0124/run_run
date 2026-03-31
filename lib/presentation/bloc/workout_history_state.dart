part of 'workout_history_bloc.dart';

enum WorkoutHistoryStatus { initial, loading, success, failure }

class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState({
    this.status = WorkoutHistoryStatus.initial,
    this.period = WorkoutPeriod.week,
    this.workoutHistoryList = const [],
    this.details = const {},
    this.failure,
  });

  final WorkoutHistoryStatus status;
  final WorkoutPeriod period;
  final List<WorkoutHistory> workoutHistoryList;
  final Map<String, WorkoutDetailHistory> details;
  final WorkoutHistoryFailure? failure;

  WorkoutHistoryState copyWith({
    WorkoutHistoryStatus? status,
    WorkoutPeriod? period,
    List<WorkoutHistory>? workoutList,
    Map<String, WorkoutDetailHistory>? details,
    Object? failure = _undefined,
  }) {
    return WorkoutHistoryState(
      status: status ?? this.status,
      period: period ?? this.period,
      workoutHistoryList: workoutList ?? this.workoutHistoryList,
      details: details ?? this.details,
      failure: failure == _undefined ? this.failure : failure as WorkoutHistoryFailure?,
    );
  }

  @override
  List<Object?> get props => [status, period, workoutHistoryList, details, failure];
}

const _undefined = Object();
