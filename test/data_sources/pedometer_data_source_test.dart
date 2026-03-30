import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:run_run/data/data_sources/pedometer_data_source.dart';
import 'package:run_run/data/models/pedometer_dto.dart';

String encodePedometer({
  String startDate = '2026-03-09T08:00:00Z',
  String endDate = '2026-03-09T08:30:00Z',
  double numberOfSteps = 1250.0,
  double? distance = 850.5,
  double? floorsAscended = 3.0,
  double? floorsDescended = 2.0,
  double? currentPace = 5.2,
  double? currentCadence = 110.0,
  double? averageActivePace = 4.8,
}) =>
    jsonEncode({
      'startDate': startDate,
      'endDate': endDate,
      'numberOfSteps': numberOfSteps,
      'distance': distance,
      'floorsAscended': floorsAscended,
      'floorsDescended': floorsDescended,
      'currentPace': currentPace,
      'currentCadence': currentCadence,
      'averageActivePace': averageActivePace,
    });

final mockPedometerJson = encodePedometer();

final mockPedometerDTO = PedometerDTO(
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

final mockPedometerDTO2 = PedometerDTO(
  startDate: '2026-03-09T09:00:00Z',
  endDate: '2026-03-09T09:30:00Z',
  numberOfSteps: 980.0,
  distance: 700.0,
  floorsAscended: 1.0,
  floorsDescended: 0.0,
  currentPace: 6.1,
  currentCadence: 105.0,
  averageActivePace: 5.9,
);

final mockPedometerJson2 = encodePedometer(
  startDate: '2026-03-09T09:00:00Z',
  endDate: '2026-03-09T09:30:00Z',
  numberOfSteps: 980.0,
  distance: 700.0,
  floorsAscended: 1.0,
  floorsDescended: 0.0,
  currentPace: 6.1,
  currentCadence: 105.0,
  averageActivePace: 5.9,
);

class MockEventChannel extends Mock implements EventChannel {}

void main() {
  late PedometerDataSource pedometerDataSource;
  late MockEventChannel mockEventChannel;

  setUp(() {
    mockEventChannel = MockEventChannel();
    pedometerDataSource = PedometerDataSource(eventChannel: mockEventChannel);
  });

  tearDown(() {
    pedometerDataSource.dispose();
  });

  // ─────────────────────────────────────────────
  // start
  // ─────────────────────────────────────────────

  group('start', () {
    test('EventChannel 스트림(String JSON)이 PedometerDTO로 파싱되어 스트림으로 전달된다', () async {
      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => Stream.value(mockPedometerJson));

      final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emits(mockPedometerDTO),
      );

      await pedometerDataSource.start();

      await expectation;
    });

    test('여러 데이터가 순서대로 PedometerDTO로 파싱된다', () async {
      when(() => mockEventChannel.receiveBroadcastStream()).thenAnswer(
          (_) => Stream.fromIterable([mockPedometerJson, mockPedometerJson2]));

      final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emitsInOrder([mockPedometerDTO, mockPedometerDTO2]),
      );

      await pedometerDataSource.start();

      await expectation;
    });

    test('Optional 필드가 null인 JSON도 정상적으로 파싱된다', () async {
      final jsonWithNulls = encodePedometer(
        distance: null,
        floorsAscended: null,
        floorsDescended: null,
        currentPace: null,
        currentCadence: null,
        averageActivePace: null,
      );

      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => Stream.value(jsonWithNulls));

      final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emits(
          isA<PedometerDTO>()
              .having((d) => d.numberOfSteps, 'numberOfSteps', 1250.0)
              .having((d) => d.distance, 'distance', isNull)
              .having((d) => d.currentPace, 'currentPace', isNull),
        ),
      );

      await pedometerDataSource.start();

      await expectation;
    });

    test('null 데이터는 스트림에 전달되지 않는다', () async {
      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => Stream.fromIterable([null, mockPedometerJson]));

      final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emitsInOrder([mockPedometerDTO]),
      );

      await pedometerDataSource.start();

      await expectation;
    });

    test('String이 아닌 타입 데이터는 스트림에 전달되지 않는다', () async {
      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => Stream.fromIterable([42, true, mockPedometerJson]));

      final expectation = expectLater(
        pedometerDataSource.pedometerDataDTOStream,
        emitsInOrder([mockPedometerDTO]),
      );

      await pedometerDataSource.start();

      await expectation;
    });

    test('start를 두 번 호출하면 기존 구독이 취소되고 새로 구독한다', () async {
      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => Stream.value(mockPedometerJson));

      await pedometerDataSource.start();
      await pedometerDataSource.start();

      verify(() => mockEventChannel.receiveBroadcastStream()).called(2);
    });
  });

  // ─────────────────────────────────────────────
  // cancel
  // ─────────────────────────────────────────────

  group('cancel', () {
    test('cancel을 호출하면 이후 스트림 데이터가 전달되지 않는다', () async {
      final controller = StreamController<dynamic>();

      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => controller.stream);

      await pedometerDataSource.start();
      await pedometerDataSource.cancel();

      final received = <PedometerDTO>[];
      pedometerDataSource.pedometerDataDTOStream.listen(received.add);

      controller.add(mockPedometerJson);
      await Future.microtask(() {});

      expect(received, isEmpty);

      await controller.close();
    });
  });

  // ─────────────────────────────────────────────
  // dispose
  // ─────────────────────────────────────────────

  group('dispose', () {
    test('dispose 이후 pedometerDataDTOStream이 닫힌다', () async {
      when(() => mockEventChannel.receiveBroadcastStream())
          .thenAnswer((_) => const Stream.empty());

      await pedometerDataSource.start();
      pedometerDataSource.dispose();

      expect(
        pedometerDataSource.pedometerDataDTOStream,
        emitsDone,
      );
    });
  });
}
