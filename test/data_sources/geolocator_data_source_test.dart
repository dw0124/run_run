import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:run_run/data/data_sources/geolocator_data_source.dart';

Position get mockPosition => Position(
    latitude: 52.561270,
    longitude: 5.639382,
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      500,
      isUtc: true,
    ),
    altitude: 3000.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0
);

Position get mockCurrentPosition => Position(
    latitude: 40.0,
    longitude: 40.0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      500,
      isUtc: true,
    ),
    altitude: 1000.0,
    altitudeAccuracy: 0.0,
    accuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0
);

class MockGeolocatorPlatform extends Mock with MockPlatformInterfaceMixin implements GeolocatorPlatform {}

void main() {
  late GeoLocatorDataSource dataSource;
  late GeolocatorPlatform mockPlatform;

  setUpAll(() {
    final LocationSettings locationSettings = AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.fitness,
      distanceFilter: 5,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    );

    registerFallbackValue(locationSettings);
  });

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    dataSource = GeoLocatorDataSource();
  });

  test("start 테스트 - Geolocator의 getPositionStream을 호출하여 Position 스트림이 전달된다", () async {
    when(() => mockPlatform.getPositionStream(
        locationSettings: any(named: 'locationSettings')
    )).thenAnswer((_) => Stream.value(mockPosition));

    final expectation = expectLater(
        dataSource.positionStream,
        emits(mockPosition)
    );

    await dataSource.start();

    verify(() => mockPlatform.getPositionStream(
      locationSettings: any(named: 'locationSettings'),
    )).called(1);

    await expectation;
  });

  test("pause 테스트 - 정지할 때 Geolocator의 getCurrentPosition으로 Position이 스트림으로 전달된다", () async {
    // start 먼저 해서 subscription 인스턴스 할당
    when(() => mockPlatform.getPositionStream(
        locationSettings: any(named: 'locationSettings')
    )).thenAnswer((_) => Stream.value(mockPosition));

    when(() => mockPlatform.getCurrentPosition(
        locationSettings: any(named: 'locationSettings')
    )).thenAnswer((_) async => mockCurrentPosition);

    await dataSource.start();

    final expectation = expectLater(
        dataSource.positionStream,
        //emits(mockPosition)
      emitsInOrder([mockPosition, mockCurrentPosition])
    );

    await dataSource.pause();

    verify(() => mockPlatform.getCurrentPosition(
      locationSettings: any(named: 'locationSettings'),
    )).called(1);

    await expectation;
  });

  tearDown(() {
    dataSource.dispose();
  });
}