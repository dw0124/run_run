import 'package:run_run/data/models/pedometer_dto.dart';
import 'package:run_run/domain/entities/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/entities/route.dart';
import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';


/// Position to Location
extension PositionMapper on Position {
  Location toLocation({
    double? distanceDelta,
    DateTime? previousTimestamp
  }) {
    return Location(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: altitude,
      altitudeAccuracy: altitudeAccuracy,
      heading: heading,
      headingAccuracy: headingAccuracy,
      speed: speed,
      speedAccuracy: speedAccuracy,
      previousTimestamp: previousTimestamp,
      distanceDelta: distanceDelta,
    );
  }
}

/// Location to Position
extension LocationMapper on Location {
  Position toPosition() {
    return Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: altitude,
        altitudeAccuracy: altitudeAccuracy,
        heading: heading,
        headingAccuracy: headingAccuracy,
        speed: speed,
        speedAccuracy: speedAccuracy
    );
  }
}

/// Pedometer to PedometerDTO
extension PedometerMapper on Pedometer {
  PedometerDTO toPedometerDTO() {
    return PedometerDTO(
      startDate: startDate,
      endDate: endDate,
      numberOfSteps: numberOfSteps,
      distance: distance,
      floorsAscended: floorsAscended,
      floorsDescended: floorsDescended,
      currentPace: currentPace,
      currentCadence: currentCadence,
      averageActivePace: averageActivePace,
    );
  }
}

/// PedometerDTO to Pedometer
extension PedometerDTOMapper on PedometerDTO {
  Pedometer toPedometer() {
    return Pedometer(
      startDate: startDate,
      endDate: endDate,
      numberOfSteps: numberOfSteps,
      distance: distance,
      floorsAscended: floorsAscended,
      floorsDescended: floorsDescended,
      currentPace: currentPace,
      currentCadence: currentCadence,
      averageActivePace: averageActivePace,
    );
  }
}

/// Raw Map to WorkoutHistory
extension WorkoutHistoryRawMapper on Map<String, dynamic> {
  WorkoutHistory toWorkoutHistory() {
    return WorkoutHistory(
      id: this['id'] as String,
      startDate: DateTime.parse(this['startDate'] as String),
      endDate: DateTime.parse(this['endDate'] as String),
      duration: (this['duration'] as num).toDouble(),
      totalDistance: (this['totalDistance'] as num).toDouble(),
      averageRunningSpeed: (this['averageRunningSpeed'] as num).toDouble(),
      totalEnergyBurned: (this['totalEnergyBurned'] as num).toDouble(),
    );
  }

  WorkoutDetailHistory toWorkoutDetailHistory(String workoutId) {
    return WorkoutDetailHistory(
      workoutId: workoutId,
      stepCountSamples: _mapSamples(this['stepCountSamples']),
      distanceSamples: _mapSamples(this['distanceSamples']),
      runningSpeedSamples: _mapSamples(this['runningSpeedSamples']),
    );
  }

  WorkoutSample toWorkoutSample() {
    return WorkoutSample(
      startDate: DateTime.parse(this['startDate'] as String),
      endDate: DateTime.parse(this['endDate'] as String),
      value: (this['value'] as num).toDouble(),
    );
  }
}

List<WorkoutSample> _mapSamples(dynamic raw) {
  if (raw == null) return [];
  return (raw as List)
      .map((e) => (e as Map<Object?, Object?>).cast<String, dynamic>().toWorkoutSample())
      .toList();
}
