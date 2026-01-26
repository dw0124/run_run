import 'package:run_run/data/data_sources/geolocator_data_source.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/data/utils/kalman_filter.dart';
import 'package:run_run/data/utils/location_outlier_filter.dart';
import 'package:run_run/domain/repositories/location_repository.dart';
import 'package:run_run/domain/entities/location.dart';

class LocationTrackingRepoImpl implements LocationRepository {

  LocationTrackingRepoImpl({
    required LocationDataSource dataSource,
  }) :  _dataSource = dataSource;

  final LocationDataSource _dataSource;

  @override
  Stream<Location> get locationStream {
    return _dataSource.positionStream
        .map((position) => PositionMapper(position).toLocation());
  }

  @override
  Future<void> start() async {
    await _dataSource.start();
  }

  @override
  void pause() {
    _dataSource.pause();
  }

  @override
  Future<void> cancel() async {
    await _dataSource.cancel();
  }

  @override
  void dispose() => _dataSource.dispose();

  @override
  void save(Location location) {

  }
}