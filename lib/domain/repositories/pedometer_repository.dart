import 'package:run_run/domain/entities/pedometer.dart';

abstract class PedometerRepo {
  Stream<Pedometer> get pedometerStream;

  void start();
  void pause();
  void cancel();
  void dispose();
}