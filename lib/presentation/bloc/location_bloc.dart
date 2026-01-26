import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/usecases/location_tracking_use_case.dart';

part 'location_event.dart';
part 'location_state.dart';

/// 사용자의 위치 스트림만 관리하는 Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required this.initLocationTrackingUseCase,
    required this.startLocationTrackingUseCase,
    required this.pauseLocationTrackingUseCase,
    required this.cancelLocationTrackingUseCase,
  }):
    _locationStream = initLocationTrackingUseCase.call(),
    super(LocationState())
  {
    on<LocationTrackingStartEvent>((event, emit) => _onStartTracking(event, emit));
    on<LocationTrackingPauseEvent>((event, emit) => _onPauseTracking(event, emit));
    on<LocationTrackingCancelEvent>((event, emit) => _onCancelTracking(event, emit));
    on<_LocationUpdatedEvent>((event, emit) => _onLocationUpdated(event, emit));
  }

  final InitLocationTrackingUseCase initLocationTrackingUseCase;
  final StartLocationTrackingUseCase startLocationTrackingUseCase;
  final PauseLocationTrackingUseCase pauseLocationTrackingUseCase;
  final CancelLocationTrackingUseCase cancelLocationTrackingUseCase;

  final Stream<Location> _locationStream;
  StreamSubscription? subscription;

  Future<void> _onStartTracking(LocationTrackingStartEvent event, Emitter<LocationState> emit) async {
    // 중복 구독 방지를 위한 기존 구독 취소
    await subscription?.cancel();

    // 실제 스트림을 시작하는 부분: repo.start 연결
    await startLocationTrackingUseCase.call();

    subscription = _locationStream.listen((location) {
      add(_LocationUpdatedEvent(location: location));
    });

    final updatedState = state.copyWith(status: LocationStatus.tracking);
    emit(updatedState);
  }

  void _onPauseTracking(LocationTrackingPauseEvent event, Emitter<LocationState> emit) {
    pauseLocationTrackingUseCase.call();

    final updatedState = state.copyWith(status: LocationStatus.paused);
    emit(updatedState);
  }

  void _onCancelTracking(LocationTrackingCancelEvent event, Emitter<LocationState> emit) {
    cancelLocationTrackingUseCase.call();

    final updatedState = state.copyWith(status: LocationStatus.canceled);
    emit(updatedState);
  }

  /// 스트림을 통해 들어오는 location으로 state를 업데이트 합니다
  void _onLocationUpdated(_LocationUpdatedEvent event, Emitter<LocationState> emit) {
    final updatedState = state.copyWith(
      status: LocationStatus.tracking,
      location: event.location
    );
    emit(updatedState);
  }
}