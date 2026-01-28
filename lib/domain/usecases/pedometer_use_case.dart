import 'package:run_run/data/repositories/pedometer_repo_impl.dart';
import 'package:run_run/domain/entities/pedometer.dart';

abstract class StartPedometerPort {
  Future<void> call();
}

abstract class PausePedometerPort {
  void call();
}

abstract class CancelPedometerPort {
  Future<void> call();
}

abstract class GetPedometerStreamPort {
  Stream<Pedometer> get pedometerStream;
}


class StartPedometerUseCase implements StartPedometerPort {
  StartPedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  @override
  Future<void> call() async => await _repo.start();
}

class PausePedometerUseCase implements PausePedometerPort {
  PausePedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  @override
  Future<void> call() async => await _repo.cancel();
}

class CancelPedometerUseCase implements CancelPedometerPort {
  CancelPedometerUseCase(this._repo);

  final PedometerRepoImpl _repo;

  @override
  Future<void> call() async => await _repo.cancel();
}

class GetPedometerStreamUseCase implements GetPedometerStreamPort {
  GetPedometerStreamUseCase(this._repo)
      : _stream = _repo.pedometerStream;

  final PedometerRepoImpl _repo;
  final Stream<Pedometer> _stream;

  /// PedometerBloc에서 사용하는 진입점
  Stream<Pedometer> call() => _stream;

  /// WorkoutUseCase에서 사용하는 포트 (getter)
  @override
  Stream<Pedometer> get pedometerStream => _stream;
}