import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer_delta.dart';

abstract class WorkoutRepository {
  void savePedometerDelta(PedometerDelta pedometerDelta);
  void saveLocation(Location location);
  Future<void> saveWorkout();
  void resetState();
}