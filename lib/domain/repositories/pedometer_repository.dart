import 'package:run_run/domain/entities/pedometer_delta.dart';

abstract class PedometerRepo {
  Stream<PedometerDelta> get pedometerDeltaStream;

  Future<void> start();
  Future<void> pause();
  Future<void> cancel();
  Future<void> dispose();
}