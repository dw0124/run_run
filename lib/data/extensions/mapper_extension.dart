import 'package:run_run/data/models/pedometer_dto.dart';
import 'package:run_run/domain/entities/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/entities/route.dart';


/// Position to Location
extension PositionMapper on Position {
  Location toLocation() {
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
