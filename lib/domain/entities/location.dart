
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
    this.previousTimestamp,
    this.distanceDelta,
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

  // 이전 좌표와 비교를 위한 속성
  final DateTime? previousTimestamp;  // 이전 좌표의 timestamp
  final double? distanceDelta;  // 이전 좌표와 현재 좌표 사이 거리

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
    DateTime? previousTimestamp,
    double? distanceDelta,
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
      previousTimestamp: previousTimestamp ?? this.previousTimestamp,
      distanceDelta: distanceDelta ?? this.distanceDelta,
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
    previousTimestamp,
    distanceDelta,
  ];
}
