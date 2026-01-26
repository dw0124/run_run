part of 'pedometer_bloc.dart';

sealed class PedometerEvent {
  const PedometerEvent();
}

final class PedometerStartEvent extends PedometerEvent {}
final class PedometerPauseEvent extends PedometerEvent {}
final class PedometerCancelEvent extends PedometerEvent {}

final class _PedometerUpdatedEvent extends PedometerEvent {
  const _PedometerUpdatedEvent({required this.pedometer});
  final Pedometer pedometer;
}