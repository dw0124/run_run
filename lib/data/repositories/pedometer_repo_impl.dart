import 'dart:async';

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
  Stream<PedometerDelta> get pedometerDeltaStream => _deltaStreamController.stream;

  final StreamController<PedometerDelta> _deltaStreamController = StreamController<PedometerDelta>.broadcast();
  StreamSubscription? _sourceSubscription;

  Future<void> _reset() async {
    // 기존 구독 해제
    await _sourceSubscription?.cancel();
    _sourceSubscription = null;

    // Delta 계산 변수 초기화
    _lastEndDate = null;
    _lastNumberOfSteps = 0;
    _lastDistance = 0;
  }

  void _init() {
    _sourceSubscription = _dataSource.pedometerDataDTOStream.listen((pedometerDTO) {
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

      _deltaStreamController.add(pedometerDelta);
    });
  }

  @override
  Future<void> start() async {
    await _reset();
    _init();
    await _dataSource.start();
  }

  @override
  Future<void> pause() async {
    await _reset();
    await _dataSource.cancel();
  }

  @override
  Future<void> cancel() async {
    await _reset();
    await _dataSource.cancel();
  }

  @override
  void dispose() {
    _reset();
    _deltaStreamController.close();
    _dataSource.dispose();
  }
}