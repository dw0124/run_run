import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:run_run/domain/entities/location.dart';

import 'package:run_run/domain/entities/route.dart';
import 'package:run_run/domain/usecases/map_use_case.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required this.requestRouteUseCase
  }): super(MapState()) {
    on<MapRequestRouteEvent>((event, emit) => _onRequestRouteMap(event, emit));
    on<MapLocationAddedEvent>((event, emit) => _onLocationAdded(event, emit));
    on<MapTrackingStatusChangedEvent>((event, emit) => _onTrackingStatusChanged(event, emit));
  }

  final RequestRouteUseCase requestRouteUseCase;

  void _onRequestRouteMap(MapRequestRouteEvent event, Emitter<MapState> emit) async {
    final route = Route(
      startX: 126.969525492,
      startY: 37.561590999574236,
      endX: 126.9956203528817,
      endY: 37.56216145788358,
      passList: [],
    );

    final coordinates = await requestRouteUseCase.call(route);
    final updatedState = state.copyWith(coordinates: coordinates);
    emit(updatedState);
  }

  void _onTrackingStatusChanged(MapTrackingStatusChangedEvent event, Emitter<MapState> emit) {
    print('_onTrackingStatusChanged: ${state.isTracking} -> ${event.isTracking}');

    final previous = state.isTracking;
    final next = event.isTracking;

    if(previous == false && next == true) {
      final nLatLngs = [...state.nLatLngs, <NLatLng>[]];
      final locations = [...state.locations, <Location>[]];

      final updatedState = state.copyWith(
        isTracking: event.isTracking,
        nLatLngs: nLatLngs,
        locations: locations,
      );
      emit(updatedState);
    }

    if(previous == true && next == false) {
      emit(state.copyWith(isTracking: false));
    }
  }

  void _onLocationAdded(MapLocationAddedEvent event, Emitter<MapState> emit) {
    final location = event.location;
    final nLatLng = NLatLng(location.latitude, location.longitude);

    final locations = List<List<Location>>.from(state.locations);
    locations.last = List<Location>.from(locations.last)..add(location);

    final nLatLngs = List<List<NLatLng>>.from(state.nLatLngs);
    nLatLngs.last = List<NLatLng>.from(nLatLngs.last)..add(nLatLng);

    final updatedState = state.copyWith(
      locations: locations,
      nLatLngs: nLatLngs,
    );
    emit(updatedState);
  }
}