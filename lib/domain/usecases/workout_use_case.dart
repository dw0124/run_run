import 'dart:async';

import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/repositories/workout_repository.dart';

abstract class LocationPort {
  Stream<Location> get locationStream;
}

abstract class PedometerPort {
  Stream<Pedometer> get pedometerStream;
}

class WorkoutUseCase {
  WorkoutUseCase(this._repo, this._locationPort, this._pedometerPort);

  final WorkoutRepository _repo;

  // Location, Pedometer UseCase를 연결하는 Port
  final LocationPort _locationPort;
  final PedometerPort _pedometerPort;

  // Port로 전달 받은 스트림 구독
  StreamSubscription<Location>? _locationSub;
  StreamSubscription<Pedometer>? _pedometerSub;

  void start() {
    // 중복 구독 방지
    if (_locationSub != null || _pedometerSub != null) return;

    // WorkoutRepository - Pedometer delta 계산용 누적 상태 초기화
    _repo.resetState();

    _locationSub = _locationPort.locationStream.listen(_repo.saveLocation);
    _pedometerSub = _pedometerPort.pedometerStream.listen(_repo.savePedometer);
  }

  Future<void> stop() async {
    await _locationSub?.cancel();
    await _pedometerSub?.cancel();
    _locationSub = null;
    _pedometerSub = null;
  }

  Future<void> save() async {
    await _repo.saveWorkout();
  }
}
