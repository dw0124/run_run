import 'dart:async';

import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/repositories/workout_repository.dart';
import 'package:run_run/domain/usecases/location_use_case.dart';
import 'package:run_run/domain/usecases/pedometer_use_case.dart';

class BindWorkoutDataUseCase {
  BindWorkoutDataUseCase(this._repo, this._locationPort, this._pedometerPort);

  final WorkoutRepository _repo;

  // Location, Pedometer UseCase를 연결하는 Port
  final GetLocationStreamPort _locationPort;
  final GetPedometerStreamPort _pedometerPort;

  // Port로 전달 받은 스트림 구독
  StreamSubscription<Location>? _locationSub;
  StreamSubscription<Pedometer>? _pedometerSub;

  void call() {
    // 중복 구독 방지
    if (_locationSub != null || _pedometerSub != null) return;
    _locationSub = _locationPort.locationStream.listen(_repo.saveLocation);
    _pedometerSub = _pedometerPort.pedometerStream.listen(_repo.savePedometer);
  }

  Future<void> dispose() async {
    await _locationSub?.cancel();
    await _pedometerSub?.cancel();
    _locationSub = null;
    _pedometerSub = null;
  }
}

class StartWorkoutUseCase {
  StartWorkoutUseCase(this._repo, this._locationPort, this._pedometerPort);

  final WorkoutRepository _repo;

  final StartLocationPort _locationPort;
  final StartPedometerPort _pedometerPort;

  Future<void> call() async {
    // WorkoutRepository - Pedometer delta 계산용 누적 상태 초기화
    _repo.resetState();

    await _locationPort.call();
    await _pedometerPort.call();
  }
}

class PauseWorkoutUseCase {
  PauseWorkoutUseCase(this._locationPort, this._pedometerPort);

  final PauseLocationPort _locationPort;
  final PausePedometerPort _pedometerPort;

  void call() {
    _locationPort.call();
    _pedometerPort.call();
  }
}

class CancelWorkoutUseCase {
  CancelWorkoutUseCase(this._locationPort, this._pedometerPort);

  final CancelLocationPort _locationPort;
  final CancelPedometerPort _pedometerPort;

  Future<void> call() async {
    await _locationPort.call();
    await _pedometerPort.call();
  }
}

class SaveWorkoutUseCase {
  SaveWorkoutUseCase(this._repo);

  final WorkoutRepository _repo;

  Future<void> call() async {
    _repo.saveWorkout();
  }
}