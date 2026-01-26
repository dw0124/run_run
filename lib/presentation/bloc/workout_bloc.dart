import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:run_run/domain/usecases/workout_use_case.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  WorkoutBloc({
    required this.workoutUseCase
  }):
    super(WorkoutState())
  {
    on<WorkoutStartEvent>((event, emit) => _onStart(event, emit));
    on<WorkoutPauseEvent>((event, emit) => _onPause(event, emit));
    on<WorkoutSaveEvent>((event, emit) => _onSave(event, emit));
    on<_WorkoutTickedEvent>((event, emit) => _onTicked(event, emit));
  }

  final WorkoutUseCase workoutUseCase;

  Timer? _timer;
  int _elapsedSeconds = 0;
  final int _saveIntervalSeconds = 5;

  void _onStart(WorkoutStartEvent event, Emitter<WorkoutState> emit) {
    _timer?.cancel();   // 기존 타이머 정리

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      add(_WorkoutTickedEvent());
    });

    workoutUseCase.start();

    emit(state.copyWith(status: WorkoutStatus.running));
  }

  Future<void> _onPause(WorkoutPauseEvent event, Emitter<WorkoutState> emit) async {
    _timer?.cancel();
    await workoutUseCase.stop();

    emit(state.copyWith(status: WorkoutStatus.paused));
  }

  Future<void> _onSave(WorkoutSaveEvent event, Emitter<WorkoutState> emit) async {
    await workoutUseCase.save();
  }

  Future<void> _onTicked(_WorkoutTickedEvent event, Emitter<WorkoutState> emit) async {
    _elapsedSeconds++;  // 경과 시간 증가

    if (_elapsedSeconds % _saveIntervalSeconds == 0) {
      // Workout 저장 관련 이벤트
      add(WorkoutSaveEvent());
    }

    // State 업데이트
    emit(state.copyWith(elapsedSeconds: _elapsedSeconds));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
