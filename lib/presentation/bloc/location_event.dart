part of 'location_bloc.dart';

sealed class LocationEvent {
  const LocationEvent();
}

final class LocationTrackingStartEvent extends LocationEvent {}
final class LocationTrackingPauseEvent extends LocationEvent {}
final class LocationTrackingCancelEvent extends LocationEvent {}

final class _LocationUpdatedEvent extends LocationEvent {
  const _LocationUpdatedEvent({required this.location});
  final Location location;
}