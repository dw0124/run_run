import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/usecases/pedometer_use_case.dart';

part 'pedometer_event.dart';
part 'pedometer_state.dart';

class PedometerBloc extends Bloc<PedometerEvent, PedometerState> {
  PedometerBloc({
    required this.initPedometerUseCase
  }):
    _pedometerStream = initPedometerUseCase.call(),
    super(PedometerState())
  {
    subscription = _pedometerStream.listen((pedometer) {
      add(_PedometerUpdatedEvent(pedometer: pedometer));
    });

    on<_PedometerUpdatedEvent>((event, emit) => _onPedometerUpdated(event, emit));
  }

  final GetPedometerStreamUseCase initPedometerUseCase;

  final Stream<Pedometer> _pedometerStream;
  StreamSubscription? subscription;

  /// 스트림을 통해 들어오는 pedometer로 state를 업데이트
  void _onPedometerUpdated(_PedometerUpdatedEvent event, Emitter<PedometerState> emit) {
    final updatedState = state.copyWith(
        status: PedometerStatus.tracking,
        pedometerList: [...state.pedometerList, event.pedometer]
    );
    emit(updatedState);
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    super.close();
  }
}