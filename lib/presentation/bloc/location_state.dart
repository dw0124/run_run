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
    this.status = LocationStatus.initial,
    this.location,
  });

  final LocationStatus status;
  final Location? location;

  LocationState copyWith({
    LocationStatus? status,
    Location? location,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [status, location];
}