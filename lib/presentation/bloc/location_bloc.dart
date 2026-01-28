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
    final updatedState = state.copyWith(
      status: LocationStatus.tracking,
      location: event.location
    );
    emit(updatedState);
  }
}