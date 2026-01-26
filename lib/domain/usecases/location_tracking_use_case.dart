import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/location_filter.dart';
import 'package:run_run/domain/repositories/location_repository.dart';
import 'package:run_run/domain/usecases/workout_use_case.dart';

class StartLocationTrackingUseCase {
  StartLocationTrackingUseCase(this._repo, this._filter);

  final LocationRepository _repo;
  final LocationFilter _filter;   // 필터 초기화

  Future<void> call() async {
    _filter.resetFilter();
    await _repo.start();
  }
}

class PauseLocationTrackingUseCase {
  PauseLocationTrackingUseCase(this._repo);

  final LocationRepository _repo;

  void call() => _repo.pause();
}

class CancelLocationTrackingUseCase {
  CancelLocationTrackingUseCase(this._repo);

  final LocationRepository _repo;

  void call() => _repo.cancel();
}

class InitLocationTrackingUseCase implements LocationPort {
  InitLocationTrackingUseCase(this._repo, this._filter)
    : _stream = _repo.locationStream.map((location) {
        final filteredLocation = _filter.apply(location);
        return filteredLocation;
      });

  final LocationRepository _repo;
  final LocationFilter _filter;

  /// 필터링 된 위치 스트림
  final Stream<Location> _stream;

  /// LocationBloc에서 사용하는 진입점
  Stream<Location> call() => _stream;

  /// WorkoutUseCase에서 사용하는 포트 (getter)
  @override
  Stream<Location> get locationStream => _stream;
}