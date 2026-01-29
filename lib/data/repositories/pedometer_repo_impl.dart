import 'package:run_run/data/data_sources/pedometer_data_source.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/domain/entities/pedometer_delta.dart';
import 'package:run_run/domain/repositories/pedometer_repository.dart';

class PedometerRepoImpl implements PedometerRepo {

  PedometerRepoImpl({required PedometerDataSource dataSource}) : _dataSource = dataSource;

  final PedometerDataSource _dataSource;

  // ----Pedometer delta 계산을 위한 변수----
  String? _lastEndDate;
  double _lastNumberOfSteps = 0;
  double _lastDistance = 0;
  // ----------------------------------

  @override
  Stream<PedometerDelta> get pedometerDeltaStream => _dataSource.pedometerDataDTOStream.map((pedometerDTO) {
    final pedometer = pedometerDTO.toPedometer();

    // 1. 시작 시간 결정
    final start = _lastEndDate ?? pedometer.startDate;

    // 2. 걸음수 Delta 계산
    double deltaSteps = pedometer.numberOfSteps - _lastNumberOfSteps;
    if (deltaSteps < 0) {
      deltaSteps = pedometer.numberOfSteps;
    }

    // 3. 거리 Delta 계산
    double deltaDistance = 0;
    if (pedometer.distance != null) {
      deltaDistance = pedometer.distance! - _lastDistance;
      if (deltaDistance < 0) {
        deltaDistance = pedometer.distance!;
      }
    }

    // 4. 상태 업데이트
    _lastNumberOfSteps = pedometer.numberOfSteps;
    _lastEndDate = pedometer.endDate;
    _lastDistance = pedometer.distance ?? _lastDistance;

    final pedometerDelta = PedometerDelta(
      startDate: start,
      endDate: pedometer.endDate,
      stepDelta: deltaSteps.toInt(),
      distanceDelta: deltaDistance,
      currentCadence: pedometer.currentCadence,
      currentPace: pedometer.currentPace,
    );

    return pedometerDelta;
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