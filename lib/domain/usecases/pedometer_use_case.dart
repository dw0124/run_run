import 'package:run_run/data/repositories/pedometer_repo_impl.dart';
import 'package:run_run/domain/entities/pedometer_delta.dart';

abstract class StartPedometerPort {
  Future<void> call();
}

abstract class PausePedometerPort {
  void call();
}

abstract class CancelPedometerPort {
  Future<void> call();
}

abstract class GetPedometerDeltaStreamPort {
  Stream<PedometerDelta> get pedometerDeltaStream;
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

class GetPedometerStreamUseCase implements GetPedometerDeltaStreamPort {
  GetPedometerStreamUseCase(this._repo)
      : _stream = _repo.pedometerDeltaStream;

  final PedometerRepoImpl _repo;
  final Stream<PedometerDelta> _stream;

  /// PedometerBloc에서 사용하는 진입점
  Stream<PedometerDelta> call() => _stream;

  /// WorkoutUseCase에서 사용하는 포트 (getter)
  @override
  Stream<PedometerDelta> get pedometerDeltaStream => _stream;
}