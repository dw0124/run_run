import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:run_run/data/data_sources/pedometer_data_source.dart';
import 'package:run_run/data/models/pedometer_dto.dart';

final String mockPedometerJson = jsonEncode({
  'startDate': '2026-03-09T08:00:00Z',
  'endDate': '2026-03-09T08:30:00Z',
  'numberOfSteps': 1250.0,
  'distance': 850.5,
  'floorsAscended': 3.0,
  'floorsDescended': 2.0,
  'currentPace': 5.2,
  'currentCadence': 110.0,
  'averageActivePace': 4.8,
});

final PedometerDTO mockPedometerDTO = PedometerDTO(
  startDate: '2026-03-09T08:00:00Z',
  endDate: '2026-03-09T08:30:00Z',
  numberOfSteps: 1250.0,
  distance: 850.5,
  floorsAscended: 3.0,
  floorsDescended: 2.0,
  currentPace: 5.2,
  currentCadence: 110.0,
  averageActivePace: 4.8,
);

class MockEventChannel extends Mock implements EventChannel {}

void main() {
  late PedometerDataSource pedometerDataSource;
  late MockEventChannel mockEventChannel;

  setUp(() {
    mockEventChannel = MockEventChannel();
    pedometerDataSource = PedometerDataSource(eventChannel: mockEventChannel);
  });

  test("start - EventChannel을 통해서 스트림(String 형태 Json)이 정상적으로 들어오고, PedometerDTO로 파싱된다", () async {
    when(() => mockEventChannel.receiveBroadcastStream())
        .thenAnswer((_) => Stream.value(mockPedometerJson));

    final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emits(mockPedometerDTO)
    );

    await pedometerDataSource.start();

    await expectation;
  });

  tearDown(() {

  });
}