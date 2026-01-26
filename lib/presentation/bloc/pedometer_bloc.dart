import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/usecases/pedometer_use_case.dart';

part 'pedometer_event.dart';
part 'pedometer_state.dart';

class PedometerBloc extends Bloc<PedometerEvent, PedometerState> {
  PedometerBloc({
    required this.initPedometerUseCase,
    required this.startPedometerUseCase,
    required this.pausePedometerUseCase,
    required this.cancelPedometerUseCase,
  }):
        _pedometerStream = initPedometerUseCase.call(),
        super(PedometerState())
  {
    on<PedometerStartEvent>((event, emit) => _onStart(event, emit));
    on<PedometerPauseEvent>((event, emit) => _onPause(event, emit));
    on<PedometerCancelEvent>((event, emit) => _onCancel(event, emit));
    on<_PedometerUpdatedEvent>((event, emit) => _onPedometerUpdated(event, emit));
  }

  final InitPedometerUseCase initPedometerUseCase;
  final StartPedometerUseCase startPedometerUseCase;
  final PausePedometerUseCase pausePedometerUseCase;
  final CancelPedometerUseCase cancelPedometerUseCase;

  final Stream<Pedometer> _pedometerStream;
  StreamSubscription? subscription;

  Future<void> _onStart(PedometerStartEvent event, Emitter<PedometerState> emit) async {
    // 이미 tracking 중이면 무시
    if(state.status == PedometerStatus.tracking) return;

    // 중복 구독 방지를 위한 기존 구독 취소
    await subscription?.cancel();

    // 실제 스트림을 시작하는 부분
    await startPedometerUseCase.call();

    subscription = _pedometerStream.listen((pedometer) {
      add(_PedometerUpdatedEvent(pedometer: pedometer));
    });

    final updatedState = state.copyWith(status: PedometerStatus.tracking);
    emit(updatedState);
  }

  Future<void> _onPause(PedometerPauseEvent event, Emitter<PedometerState> emit) async {
    await pausePedometerUseCase.call();

    final updatedState = state.copyWith(status: PedometerStatus.paused);
    emit(updatedState);
  }

  Future<void> _onCancel(PedometerCancelEvent event, Emitter<PedometerState> emit) async {
    await subscription?.cancel();
    await cancelPedometerUseCase.call();

    final updatedState = state.copyWith(status: PedometerStatus.canceled);
    emit(updatedState);
  }

  /// 스트림을 통해 들어오는 pedometer로 state를 업데이트
  void _onPedometerUpdated(_PedometerUpdatedEvent event, Emitter<PedometerState> emit) {
    final updatedState = state.copyWith(
        status: PedometerStatus.tracking,
        pedometerList: [...state.pedometerList, event.pedometer]
    );

    print("steps: ${event.pedometer.numberOfSteps}");
    print("distance: ${event.pedometer.distance}");
    print("currentPade: ${event.pedometer.currentPace}");
    print("currentCadence: ${event.pedometer.currentCadence}");

    emit(updatedState);
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    super.close();
  }
}