import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/usecases/location_use_case.dart';

part 'location_event.dart';
part 'location_state.dart';

/// 사용자의 위치 스트림만 관리하는 Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({
    required this.initLocationTrackingUseCase,
  }):
    _locationStream = initLocationTrackingUseCase.call(),
    super(LocationState())
  {
    subscription = _locationStream.listen((location) {
      add(_LocationUpdatedEvent(location: location));
    });

    on<_LocationUpdatedEvent>((event, emit) => _onLocationUpdated(event, emit));
  }

  final GetLocationStreamUseCase initLocationTrackingUseCase;

  Stream<Location> _locationStream;
  StreamSubscription? subscription;

  /// 스트림을 통해 들어오는 location으로 state를 업데이트 합니다
  void _onLocationUpdated(_LocationUpdatedEvent event, Emitter<LocationState> emit) {
    final location = event.location;
    final distanceDelta = location.distanceDelta;

    final previousTimestamp = location.previousTimestamp;
    final currentTimestamp = location.timestamp;

    // distanceDelta가 null이면 거리 누적 없이 위치만 업데이트
    if (distanceDelta == null) {
      emit(state.copyWith(
        status: LocationStatus.tracking,
        location: location,
      ));
      return;
    }

    // currentPace 계산해서 업데이트
    double? currentPace;

    if(previousTimestamp != null) {
      final timeDeltaMs = currentTimestamp.difference(previousTimestamp).inMilliseconds;

      // 거리가 0이거나 시간 차이가 없을 경우
      if (distanceDelta > 0 && timeDeltaMs > 0) {
        final seconds = timeDeltaMs / 1000;
        final secondsPerMeter = seconds / distanceDelta;
        currentPace = secondsPerMeter * 1000;
      }
    }

    // distanceDelta가 존재할 때만 총 거리 업데이트
    emit(state.copyWith(
      status: LocationStatus.tracking,
      location: location,
      totalDistance: state.totalDistance + distanceDelta,
      currentPace: currentPace,
    ));
  }
}