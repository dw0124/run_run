import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:run_run/data/data_sources/geolocator_data_source.dart';

Position get mockPosition => Position(
    latitude: 52.561270,
    longitude: 5.639382,
    timestamp: DateTime.fromMillisecondsSinceEpoch(500, isUtc: true),
    altitude: 3000.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);

Position get mockPosition2 => Position(
    latitude: 37.5665,
    longitude: 126.9780,
    timestamp: DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
    altitude: 50.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 2.5,
    speedAccuracy: 0.0);

Position get mockCurrentPosition => Position(
    latitude: 40.0,
    longitude: 40.0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(500, isUtc: true),
    altitude: 1000.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

void main() {
  late GeoLocatorDataSource dataSource;
  late MockGeolocatorPlatform mockPlatform;

  setUpAll(() {
    registerFallbackValue(AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.fitness,
      distanceFilter: 5,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    ));
  });

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    dataSource = GeoLocatorDataSource();
  });

  tearDown(() {
    dataSource.dispose();
  });

  // ─────────────────────────────────────────────
  // start
  // ─────────────────────────────────────────────

  group('start', () {
    test('getPositionStream이 호출되고 Position이 스트림으로 전달된다', () async {
      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => Stream.value(mockPosition));

      final expectation = expectLater(
        dataSource.positionStream,
        emits(mockPosition),
      );

      await dataSource.start();

      verify(() => mockPlatform.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          )).called(1);

      await expectation;
    });

    test('여러 Position이 순서대로 스트림으로 전달된다', () async {
      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => Stream.fromIterable([mockPosition, mockPosition2]));

      final expectation = expectLater(
        dataSource.positionStream,
        emitsInOrder([mockPosition, mockPosition2]),
      );

      await dataSource.start();

      await expectation;
    });

    test('start를 두 번 호출하면 기존 구독이 취소되고 새로 구독한다', () async {
      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => Stream.value(mockPosition));

      await dataSource.start();
      await dataSource.start();

      verify(() => mockPlatform.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          )).called(2);
    });
  });

  // ─────────────────────────────────────────────
  // pause
  // ─────────────────────────────────────────────

  group('pause', () {
    test('getCurrentPosition이 호출되고 마지막 Position이 스트림으로 추가 전달된다', () async {
      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => Stream.value(mockPosition));

      when(() => mockPlatform.getCurrentPosition(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) async => mockCurrentPosition);

      await dataSource.start();

      final expectation = expectLater(
        dataSource.positionStream,
        emitsInOrder([mockPosition, mockCurrentPosition]),
      );

      await dataSource.pause();

      verify(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).called(1);

      await expectation;
    });
  });

  // ─────────────────────────────────────────────
  // cancel
  // ─────────────────────────────────────────────

  group('cancel', () {
    test('cancel을 호출하면 이후 스트림 데이터가 전달되지 않는다', () async {
      final controller = StreamController<Position>();

      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => controller.stream);

      await dataSource.start();
      await dataSource.cancel();

      final received = <Position>[];
      dataSource.positionStream.listen(received.add);

      controller.add(mockPosition);
      await Future.microtask(() {});

      expect(received, isEmpty);

      await controller.close();
    });
  });

  // ─────────────────────────────────────────────
  // dispose
  // ─────────────────────────────────────────────

  group('dispose', () {
    test('dispose 이후 positionStream이 닫힌다', () async {
      when(() => mockPlatform.getPositionStream(
              locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) => const Stream.empty());

      await dataSource.start();
      dataSource.dispose();

      expect(
        dataSource.positionStream,
        emitsDone,
      );
    });
  });
}
