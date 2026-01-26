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

  void reset() => _lastLocation = null;
}