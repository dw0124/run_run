part of 'location_bloc.dart';

enum LocationStatus {
  initial,
  tracking,
  paused,
  canceled,
  error,
}

class LocationState extends Equatable {

  const LocationState({
    this.totalDistance = 0,
    this.status = LocationStatus.initial,
    this.location,
    this.currentPace,
  });

  final LocationStatus status;
  final Location? location;

  final double totalDistance;
  final double? currentPace;

  LocationState copyWith({
    LocationStatus? status,
    Location? location,
    double? totalDistance,
    Object? currentPace = _undefined,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      totalDistance: totalDistance ?? this.totalDistance,
      currentPace: currentPace == _undefined ? this.currentPace : currentPace as double?,
    );
  }

  @override
  List<Object?> get props => [status, location, totalDistance, currentPace];
}

const _undefined = Object();