import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:run_run/domain/entities/pedometer_delta.dart';
import 'package:run_run/domain/usecases/pedometer_use_case.dart';

part 'pedometer_event.dart';
part 'pedometer_state.dart';

class PedometerBloc extends Bloc<PedometerEvent, PedometerState> {
  PedometerBloc({
    required this.initPedometerUseCase
  }):
    _pedometerDeltaStream = initPedometerUseCase.call(),
    super(PedometerState())
  {
    subscription = _pedometerDeltaStream.listen((pedometerDelta) {
      add(_PedometerUpdatedEvent(pedometerDelta: pedometerDelta));
    });

    on<_PedometerUpdatedEvent>((event, emit) => _onPedometerUpdated(event, emit));
  }

  final GetPedometerStreamUseCase initPedometerUseCase;

  final Stream<PedometerDelta> _pedometerDeltaStream;
  StreamSubscription? subscription;

  /// 스트림을 통해 들어오는 pedometer로 state를 업데이트
  void _onPedometerUpdated(_PedometerUpdatedEvent event, Emitter<PedometerState> emit) {
    final delta = event.pedometerDelta;

    final updatedState = state.copyWith(
      totalSteps: state.totalSteps + delta.stepDelta,
      totalDistance: state.totalDistance + delta.distanceDelta,
      currentPace: delta.currentPace ?? state.currentPace,
      currentCadence: delta.currentCadence ?? state.currentCadence,
    );

    emit(updatedState);
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    super.close();
  }
}