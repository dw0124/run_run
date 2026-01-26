import 'package:run_run/data/repositories/pedometer_repo_impl.dart';
import 'package:run_run/domain/entities/pedometer.dart';
import 'package:run_run/domain/usecases/workout_use_case.dart';

class StartPedometerUseCase {
  StartPedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  Future<void> call() async => await _repo.start();
}

class PausePedometerUseCase {
  PausePedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  Future<void> call() async => await _repo.cancel();
}

class CancelPedometerUseCase {
  CancelPedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  Future<void> call() async => await _repo.cancel();
}

class InitPedometerUseCase implements PedometerPort {
  InitPedometerUseCase(this._repo)
      : _stream = _repo.pedometerStream;

  final PedometerRepoImpl _repo;
  final Stream<Pedometer> _stream;

  /// PedometerBloc에서 사용하는 진입점
  Stream<Pedometer> call() => _stream;

  /// WorkoutUseCase에서 사용하는 포트 (getter)
  @override
  Stream<Pedometer> get pedometerStream => _stream;
}