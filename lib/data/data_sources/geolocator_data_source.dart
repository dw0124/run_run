import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {

  Stream<Position> get positionStream;

  LocationDataSource();

  Future<void> start();
  void pause();
  Future<void> cancel();
  void dispose();
}

class GeoLocatorDataSource implements LocationDataSource {

  GeoLocatorDataSource() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 5),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      _locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
      );
    }

    _controller = StreamController<Position>.broadcast();
  }

  late LocationSettings _locationSettings;

  late StreamController<Position> _controller;
  StreamSubscription<Position>? _subscription;

  @override
  Stream<Position> get positionStream => _controller.stream;

  @override
  Future<void> start() async {
    await _subscription?.cancel();

    // Geolocator 스트림 구독하고 _controller에 전달
    _subscription = Geolocator.getPositionStream(locationSettings: _locationSettings).listen((position) {
      _controller.add(position);
    });
  }

  @override
  void pause() {
    _subscription?.pause();
  }

  @override
  Future<void> cancel() async {
    await _subscription?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}