import 'package:run_run/data/utils/kalman_filter.dart';
import 'package:run_run/data/utils/location_outlier_filter.dart';
import 'package:run_run/domain/entities/location.dart';

class LocationFilter {
  LocationFilter({
    LocationOutlierFilter? outlierFilter,
    KalmanFilter? latKalmanFilter,
    KalmanFilter? lngKalmanFilter,
  }) :  _outlierFilter = outlierFilter ?? LocationOutlierFilter(),
        _latKalmanFilter = latKalmanFilter ?? KalmanFilter(),
        _lngKalmanFilter = lngKalmanFilter ?? KalmanFilter();

  // GPS 이상치 제거를 위한 필터
  final LocationOutlierFilter _outlierFilter;

  // lat, lng 칼만 필터
  final KalmanFilter _latKalmanFilter;
  final KalmanFilter _lngKalmanFilter;

  bool isOutlier(Location location) =>
      _outlierFilter.isOutlier(location);

  Location apply(Location location) {
    final lat = _latKalmanFilter.update(
      measurement: location.latitude,
      accuracy: location.accuracy,
      speed: location.speed,
    );

    final lng = _lngKalmanFilter.update(
      measurement: location.longitude,
      accuracy: location.accuracy,
      speed: location.speed,
    );

    return location.copyWith(
      latitude: lat,
      longitude: lng,
    );
  }

  // 필터 초기화
  void resetFilter() {
    _outlierFilter.reset();
    _latKalmanFilter.reset();
    _lngKalmanFilter.reset();
  }
}