import 'package:run_run/domain/entities/location.dart';

abstract class LocationRepository {
  Stream<Location> get locationStream;

  Future<void> start();
  Future<void> pause();
  Future<void> cancel();
  Future<void> dispose();
}