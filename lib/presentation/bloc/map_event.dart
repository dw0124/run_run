part of 'map_bloc.dart';

sealed class MapEvent {
  const MapEvent();
}

final class MapRequestRouteEvent extends MapEvent {}

final class MapTrackingStatusChangedEvent extends MapEvent {
  const MapTrackingStatusChangedEvent(this.isTracking);
  final bool isTracking;
}

final class MapLocationAddedEvent extends MapEvent {
  const MapLocationAddedEvent(this.location);
  final Location location;
}