import 'package:geolocator/geolocator.dart';
import 'package:run_run/domain/entities/location.dart';

class LocationOutlierFilter {

  LocationOutlierFilter() {}

  Location? _lastLocation;

  static const double _maxSpeed = 15.0;  // 미터 단위, 54km/h

  bool isOutlier(Location location) {
    if(_lastLocation == null) {
      _lastLocation = location;
      return false;
    }

    // CLLocation speedAccuracy 검사
    if(location.speedAccuracy < 0) {
      return true;
    }

    // CLLocation speed 검사 (음수거나 _maxSpeed 초과 시 이상치)
    if (location.speed < 0 || location.speed > _maxSpeed) {
      return true;
    }

    // _lastLocation 업데이트
    _lastLocation = location;
    return false;
  }

  bool isOutlierPosition(Position position) {

    // CLLocation speedAccuracy 검사
    if(position.speedAccuracy < 0) {
      return true;
    }

    // Position 데이터의 신뢰도 검사
    if (position.accuracy > 20) {
      return true;
    }

    // CLLocation speed 검사 (음수거나 _maxSpeed 초과 시 이상치)
    if (position.speed < 0 || position.speed > _maxSpeed) {
      return true;
    }

    return false;
  }

  void reset() => _lastLocation = null;
}