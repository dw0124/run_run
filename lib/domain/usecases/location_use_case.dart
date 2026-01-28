import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/location_filter.dart';
import 'package:run_run/domain/repositories/location_repository.dart';

abstract class StartLocationPort {
  Future<void> call();
}

abstract class PauseLocationPort {
  void call();
}

abstract class CancelLocationPort {
  Future<void> call();
}

abstract class GetLocationStreamPort {
  Stream<Location> get locationStream;
}

class StartLocationUseCase implements StartLocationPort {
  StartLocationUseCase(this._repo, this._filter);

  final LocationRepository _repo;
  final LocationFilter _filter;   // 필터 초기화를 위한 상수

  @override
  Future<void> call() async {
    _filter.resetFilter();
    await _repo.start();
  }
}

class PauseLocationUseCase implements PauseLocationPort {
  PauseLocationUseCase(this._repo);

  final LocationRepository _repo;

  @override
  void call() {
    _repo.pause();
  }
}

class CancelLocationUseCase implements CancelLocationPort {
  CancelLocationUseCase(this._repo);

  final LocationRepository _repo;

  @override
  Future<void> call() async {
    await _repo.cancel();
  }
}

class GetLocationStreamUseCase implements GetLocationStreamPort {
  GetLocationStreamUseCase(LocationRepository repo, LocationFilter filter)
    : _stream = repo.locationStream
      // 이상치(Outlier)인 경우 걸러냄
      .where((location) => !filter.isOutlier(location))
      // 이상치(Outlier)가 아닌 경우 필터 적용
      .map((location) => filter.apply(location));

  /// 필터링 된 위치 스트림
  final Stream<Location> _stream;

  /// LocationBloc에서 사용하는 진입점
  Stream<Location> call() => _stream;

  /// WorkoutUseCase에서 사용하는 포트 (getter)
  @override
  Stream<Location> get locationStream => _stream;
}