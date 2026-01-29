import 'package:run_run/domain/entities/pedometer_delta.dart';

abstract class PedometerRepo {
  Stream<PedometerDelta> get pedometerDeltaStream;

  void start();
  void pause();
  void cancel();
  void dispose();
}