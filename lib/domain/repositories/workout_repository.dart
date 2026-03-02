import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer_delta.dart';

abstract class WorkoutRepository {
  Future<void> startWorkout();
  Future<void> pauseWorkout();
  Future<void> finishWorkout();

  void savePedometerDelta(PedometerDelta pedometerDelta);
  void saveLocation(Location location);
  Future<void> saveWorkout();
  void resetState();
}