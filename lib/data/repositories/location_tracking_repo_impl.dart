import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:run_run/data/data_sources/geolocator_data_source.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/data/utils/location_outlier_filter.dart';
import 'package:run_run/domain/repositories/location_repository.dart';
import 'package:run_run/domain/entities/location.dart';

class LocationTrackingRepoImpl implements LocationRepository {

  LocationTrackingRepoImpl({
    required LocationDataSource dataSource,
  }) :  _dataSource = dataSource;

  final LocationDataSource _dataSource;

  final StreamController<Location> _streamController = StreamController<Location>.broadcast();
  StreamSubscription? _sourceSubscription;

  final _filter = LocationOutlierFilter();
  Position? _previousPosition;

  void _init() {
    _sourceSubscription = _dataSource.positionStream.listen((position) {
      final location = _processPosition(position);

      if(location != null) {
        _streamController.add(location);
      }
    });
  }

  @override
  Stream<Location> get locationStream => _streamController.stream;

  @override
  Future<void> start() async {
    await _reset();
    _init();
    await _dataSource.start();
  }

  @override
  Future<void> pause() async {
    await _dataSource.pause();
    _reset();
  }

  @override
  Future<void> cancel() async {
    _reset();
    await _dataSource.cancel();
  }

  @override
  void dispose() {
    _dataSource.dispose();
    _reset();
    _streamController.close();
  }

  @override
  void save(Location location) {

  }

  /// 좌표의 이상치를 필터링하고 거리를 계산하여 Location 엔티티로 변환
  Location? _processPosition(Position position) {
    // 이상치 필터링
    if (_filter.isOutlierPosition(position)) return null;

    DateTime? previousTimestamp = _previousPosition?.timestamp;
    double? distanceDelta;

    // 거리 계산
    if (_previousPosition != null) {
      distanceDelta = Geolocator.distanceBetween(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }

    // 상태 업데이트
    _previousPosition = position;

    return PositionMapper(position)
        .toLocation(
        distanceDelta: distanceDelta,
        previousTimestamp: previousTimestamp
    );
  }

  Future<void> _reset() async {
    await _sourceSubscription?.cancel();
    _sourceSubscription = null;
    _previousPosition = null;
  }
}