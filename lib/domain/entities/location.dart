
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    required this.longitude,
    required this.latitude,
    required this.timestamp,
    required this.accuracy,
    required this.altitude,
    required this.altitudeAccuracy,
    required this.heading,
    required this.headingAccuracy,
    required this.speed,
    required this.speedAccuracy,
    this.floor,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double altitude;
  final double altitudeAccuracy;
  final double accuracy;          // horizontalAccuracy
  final double heading;
  final double headingAccuracy;
  final int? floor;
  final double speed;
  final double speedAccuracy;

  Location copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? altitude,
    double? altitudeAccuracy,
    double? accuracy,
    double? heading,
    double? headingAccuracy,
    int? floor,
    double? speed,
    double? speedAccuracy,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      altitudeAccuracy: altitudeAccuracy ?? this.altitudeAccuracy,
      accuracy: accuracy ?? this.accuracy,
      heading: heading ?? this.heading,
      headingAccuracy: headingAccuracy ?? this.headingAccuracy,
      floor: floor ?? this.floor,
      speed: speed ?? this.speed,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
    );
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    timestamp,
    altitude,
    altitudeAccuracy,
    accuracy,
    heading,
    headingAccuracy,
    floor,
    speed,
    speedAccuracy,
  ];
}
