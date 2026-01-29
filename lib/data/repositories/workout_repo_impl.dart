import 'package:run_run/data/data_sources/workout_data_source.dart';
import 'package:run_run/data/extensions/mapper_extension.dart';
import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer_delta.dart';
import 'package:run_run/domain/repositories/workout_repository.dart';

class WorkoutRepoImpl implements WorkoutRepository {

  WorkoutRepoImpl({
    required WorkoutDataSource dataSource,
  }) :  _dataSource = dataSource;

  final WorkoutDataSource _dataSource;

  final List<Map<String, dynamic>> _positionBuffer = [];
  final List<Map<String, dynamic>> _pedometerBuffer = [];

  /// UseCase에서 _positionBuffer에 추가하는 함수
  @override
  void saveLocation(Location location) {
    final position = LocationMapper(location).toPosition();
    final data = position.toJson();
    _positionBuffer.add(data);
  }

  /// UseCase에서 _pedometerDTOBuffer에 추가하는 함수
  @override
  void savePedometerDelta(PedometerDelta pedometerDelta) {
    final data = pedometerDelta.toJson();
    _pedometerBuffer.add(data);
  }

  /// 메소드 채널을 통해 HealthKit에 저장하기 위해
  /// DataSource로 Workout을 전달하는 함수
  @override
  Future<void> saveWorkout() async {
    // 1. 현재 버퍼를 스냅샷으로 분리
    final locations = List<Map<String, dynamic>>.from(_positionBuffer);
    final pedometers = List<Map<String, dynamic>>.from(_pedometerBuffer);

    // 2. 분리 후 즉시 비워서, await 동안 들어오는 데이터는 새로 쌓이게
    _positionBuffer.clear();
    _pedometerBuffer.clear();

    // 3. 스냅샷만 저장
    final workout = <String, dynamic>{
      'locationSamples': locations,
      'pedometerSamples': pedometers,
    };

    try {
      await _dataSource.saveWorkout(workout);
    } catch (e) {
      // 실패 시 버퍼 복구
      _positionBuffer.insertAll(0, locations);
      _pedometerBuffer.insertAll(0, pedometers);
      rethrow;
    }
  }


  @override
  void resetState() {
    _positionBuffer.clear();
    _pedometerBuffer.clear();
  }
}