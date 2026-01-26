import 'package:run_run/domain/entities/location.dart';
import 'package:run_run/domain/entities/pedometer.dart';

abstract class WorkoutRepository {
  void savePedometer(Pedometer pedometer);
  void saveLocation(Location location);
  Future<void> saveWorkout();
  void resetState();
}