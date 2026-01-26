import 'package:run_run/domain/entities/location.dart';

abstract class LocationRepository {
  Stream<Location> get locationStream;

  Future<void> start();
  void pause();
  void cancel();
  void dispose();

  // HealthKit에 저장할 데이터를 버퍼에 추가하는 메소드
  void save(Location location);
}