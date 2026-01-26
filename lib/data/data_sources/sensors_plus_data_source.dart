import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorsPlusDataSource {

  SensorsPlusDataSource() {
    _controller = StreamController.broadcast();
  }

  late StreamController _controller;
  StreamSubscription? _subscription;

  Duration sensorInterval = SensorInterval.gameInterval;

  Stream get stream => _controller.stream;

  Future<void> start() async {
    await _subscription?.cancel();

    userAccelerometerEventStream(samplingPeriod: sensorInterval).listen((UserAccelerometerEvent event) {
          final now = event.timestamp;
          _controller.add(event);
    });
  }

  void pause() {
    _subscription?.pause();
  }

  Future<void> cancel() async {
    await _subscription?.cancel();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}