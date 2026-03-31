import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';
import 'package:run_run/domain/errors/workout_history_failure.dart';
import 'package:run_run/domain/usecases/workout_history_use_case.dart';
import 'package:run_run/shared/result.dart';

part 'workout_history_event.dart';
part 'workout_history_state.dart';

enum WorkoutPeriod { week, month, year }

class WorkoutHistoryBloc extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  WorkoutHistoryBloc({
    required FetchWorkoutHistoryListUseCase fetchWorkoutHistoryListUseCase,
    required FetchWorkoutHistoryDetailsUseCase fetchWorkoutHistoryDetailsUseCase,
  }):
    _fetchWorkoutHistoryListUseCase = fetchWorkoutHistoryListUseCase,
    _fetchWorkoutHistoryDetailsUseCase = fetchWorkoutHistoryDetailsUseCase,
    super(const WorkoutHistoryState())
  {
    on<WorkoutHistoryLoadEvent>((event, emit) => _onLoad(event, emit));
    on<WorkoutHistoryFetchDetailsEvent>((event, emit) => _onFetchDetails(event, emit));
  }

  final FetchWorkoutHistoryListUseCase _fetchWorkoutHistoryListUseCase;
  final FetchWorkoutHistoryDetailsUseCase _fetchWorkoutHistoryDetailsUseCase;

  /// 기간 필터 변경 또는 초기 진입 시 러닝 기록 목록을 로드
  Future<void> _onLoad(WorkoutHistoryLoadEvent event, Emitter<WorkoutHistoryState> emit) async {
    emit(state.copyWith(status: WorkoutHistoryStatus.loading, period: event.period));

    final (startDate, endDate) = _dateRange(event.period);
    final result = await _fetchWorkoutHistoryListUseCase.call(
      startDate: startDate,
      endDate: endDate,
    );

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(
          status: WorkoutHistoryStatus.success,
          workoutList: value,
          failure: null,
        ));
      case Failure(:final failure):
        emit(state.copyWith(
          status: WorkoutHistoryStatus.failure,
          failure: failure as WorkoutHistoryFailure,
        ));
    }
  }

  /// 이미 캐시된 상세 데이터가 있으면 요청 생략
  Future<void> _onFetchDetails(
    WorkoutHistoryFetchDetailsEvent event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    if (state.details.containsKey(event.workoutId)) return;

    final result = await _fetchWorkoutHistoryDetailsUseCase.call(workoutId: event.workoutId);

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(
          details: {...state.details, event.workoutId: value},
          failure: null,
        ));
      case Failure(:final failure):
        emit(state.copyWith(
          status: WorkoutHistoryStatus.failure,
          failure: failure as WorkoutHistoryFailure,
        ));
    }
  }

  /// WorkoutPeriod를 startDate ~ endDate 범위로 변환
  (DateTime, DateTime) _dateRange(WorkoutPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      WorkoutPeriod.week  => (today.subtract(const Duration(days: 7)), now),
      WorkoutPeriod.month => (DateTime(now.year, now.month, 1), now),
      WorkoutPeriod.year  => (DateTime(now.year, 1, 1), now),
    };
  }
}
