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
  });

  final LocationStatus status;
  final Location? location;

  final double totalDistance;

  LocationState copyWith({
    LocationStatus? status,
    Location? location,
    double? totalDistance,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }

  @override
  List<Object?> get props => [status, location, totalDistance];
}