import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:run_run/domain/usecases/workout_use_case.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  WorkoutBloc({
    required StartWorkoutUseCase startWorkoutUseCase,
    required PauseWorkoutUseCase pauseWorkoutUseCase,
    required CancelWorkoutUseCase cancelWorkoutUseCase,
    required SaveWorkoutUseCase saveWorkoutUseCase,
    required BindWorkoutDataUseCase bindWorkoutDataUseCase,
  }):
    _startWorkoutUseCase = startWorkoutUseCase,
    _pauseWorkoutUseCase = pauseWorkoutUseCase,
    _cancelWorkoutUseCase = cancelWorkoutUseCase,
    _saveWorkoutUseCase = saveWorkoutUseCase,
    _bindWorkoutDataUseCase = bindWorkoutDataUseCase,
    super(WorkoutState())
  {
    // 운동 데이터 스트림(Location, Pedometer)과 저장소(Repository) 로직을 연결
    // Bloc이 살아있는 동안 데이터가 발생하면 자동으로 저장되도록 바인딩
    // Bloc이 close될 때 dispose 메서드에 의해 해제
    _bindWorkoutDataUseCase.call();

    on<WorkoutStartEvent>((event, emit) => _onStart(event, emit));
    on<WorkoutPauseEvent>((event, emit) => _onPause(event, emit));
    on<WorkoutCancelEvent>((event, emit) => _onCancel(event, emit));
    on<WorkoutSaveEvent>((event, emit) => _onSave(event, emit));
    on<_WorkoutTickedEvent>((event, emit) => _onTicked(event, emit));
  }

  final StartWorkoutUseCase _startWorkoutUseCase;
  final PauseWorkoutUseCase _pauseWorkoutUseCase;
  final CancelWorkoutUseCase _cancelWorkoutUseCase;
  final SaveWorkoutUseCase _saveWorkoutUseCase;
  final BindWorkoutDataUseCase _bindWorkoutDataUseCase;

  Timer? _timer;
  int _elapsedSeconds = 0;
  final int _saveIntervalSeconds = 5;

  Future<void> _onStart(WorkoutStartEvent event, Emitter<WorkoutState> emit) async {
    _timer?.cancel();   // 기존 타이머 정리

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      add(_WorkoutTickedEvent());
    });

    await _startWorkoutUseCase.call();

    emit(state.copyWith(status: WorkoutStatus.running));
  }

  Future<void> _onPause(WorkoutPauseEvent event, Emitter<WorkoutState> emit) async {
    _timer?.cancel();

    _pauseWorkoutUseCase.call();

    emit(state.copyWith(status: WorkoutStatus.paused));
  }

  Future<void> _onCancel(WorkoutCancelEvent event, Emitter<WorkoutState> emit) async {
    _cancelWorkoutUseCase.call();

    emit(state.copyWith(status: WorkoutStatus.canceled));
  }

  Future<void> _onSave(WorkoutSaveEvent event, Emitter<WorkoutState> emit) async {
    await _saveWorkoutUseCase.call();
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
  Future<void> close() async {
    _timer?.cancel();
    await _bindWorkoutDataUseCase.dispose();

    return super.close();
  }
}
