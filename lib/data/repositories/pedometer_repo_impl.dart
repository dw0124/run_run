import 'package:run_run/data/data_sources/pedometer_data_source.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/repositories/pedometer_repository.dart';

class PedometerRepoImpl implements PedometerRepo {

  PedometerRepoImpl({required PedometerDataSource dataSource}) : _dataSource = dataSource;

  final PedometerDataSource _dataSource;

  @override
  Stream<Pedometer> get pedometerStream => _dataSource.pedometerDataDTOStream.map((pedometer) {
    return PedometerDTOMapper(pedometer).toPedometer();
  });

  @override
  Future<void> start() async {
    await _dataSource.start();
  }

  @override
  Future<void> pause() async {
    await _dataSource.cancel();
  }

  @override
  Future<void> cancel() async {
    await _dataSource.cancel();
  }

  @override
  void dispose() => _dataSource.dispose();
}