import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:run_run/data/data_sources/workout_history_data_source.dart';
import 'package:run_run/data/errors/workout_history_exception.dart';
import 'package:run_run/shared/result.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

final List<Map<String, dynamic>> mockWorkoutList = [
  {
    'id': 'uuid-1111',
    'startDate': '2026-03-01T08:00:00Z',
    'endDate': '2026-03-01T08:30:00Z',
    'duration': 1800.0,
    'totalDistance': 5000.0,
    'averageRunningSpeed': 2.78,
    'totalEnergyBurned': 320.0,
  },
  {
    'id': 'uuid-2222',
    'startDate': '2026-03-05T07:00:00Z',
    'endDate': '2026-03-05T07:25:00Z',
    'duration': 1500.0,
    'totalDistance': 3800.0,
    'averageRunningSpeed': 2.53,
    'totalEnergyBurned': 250.0,
  },
];

final Map<String, dynamic> mockWorkoutDetails = {
  'stepCountSamples': [
    {'startDate': '2026-03-01T08:00:00Z', 'endDate': '2026-03-01T08:01:00Z', 'value': 130.0},
    {'startDate': '2026-03-01T08:01:00Z', 'endDate': '2026-03-01T08:02:00Z', 'value': 128.0},
  ],
  'distanceSamples': [
    {'startDate': '2026-03-01T08:00:00Z', 'endDate': '2026-03-01T08:01:00Z', 'value': 165.0},
    {'startDate': '2026-03-01T08:01:00Z', 'endDate': '2026-03-01T08:02:00Z', 'value': 162.0},
  ],
  'runningSpeedSamples': [
    {'startDate': '2026-03-01T08:00:00Z', 'endDate': '2026-03-01T08:01:00Z', 'value': 2.75},
    {'startDate': '2026-03-01T08:01:00Z', 'endDate': '2026-03-01T08:02:00Z', 'value': 2.70},
  ],
};

void main() {
  late HealthKitWorkoutHistoryDataSource dataSource;
  late MockMethodChannel mockChannel;

  setUp(() {
    mockChannel = MockMethodChannel();
    dataSource = HealthKitWorkoutHistoryDataSource(methodChannel: mockChannel);
  });

  // ─────────────────────────────────────────────
  // fetchWorkoutList
  // ─────────────────────────────────────────────

  group('fetchWorkoutList', () {
    test('Success - 메서드명이 fetchWorkoutList로 호출된다', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => mockWorkoutList);

      await dataSource.fetchWorkoutList(startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 3, 19));

      verify(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any())).called(1);
    });

    test('Success - startDate, endDate가 ISO8601 문자열로 전달된다', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => mockWorkoutList);

      final startDate = DateTime(2026, 1, 1);
      final endDate = DateTime(2026, 3, 19);
      await dataSource.fetchWorkoutList(startDate: startDate, endDate: endDate);

      final captured = verify(
        () => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', captureAny()),
      ).captured;
      final args = captured.first as Map;
      expect(args['startDate'], startDate.toIso8601String());
      expect(args['endDate'], endDate.toIso8601String());
    });

    test('Success - iOS 응답이 Success(List<Map>)으로 반환된다', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => mockWorkoutList);

      final result = await dataSource.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 19),
      );

      expect(result, isA<Success<List<Map<String, dynamic>>>>());
      final workouts = (result as Success).value;
      expect(workouts.length, 2);
      expect(workouts[0]['id'], 'uuid-1111');
      expect(workouts[0]['totalDistance'], 5000.0);
      expect(workouts[1]['id'], 'uuid-2222');
    });

    test('Success - iOS가 빈 배열을 반환하면 Success(빈 리스트)를 반환한다', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => <Map<String, dynamic>>[]);

      final result = await dataSource.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 19),
      );

      expect(result, isA<Success<List<Map<String, dynamic>>>>());
      expect((result as Success).value, isEmpty);
    });

    test('Failure - FETCH_FAILED → Failure(WorkoutFetchFailedException)', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'FETCH_FAILED', message: '조회 실패'));

      final result = await dataSource.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 19),
      );

      expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      expect((result as Failure).failure, isA<WorkoutFetchFailedException>());
    });

    test('Failure - NOT_FOUND → Failure(WorkoutNotFoundException)', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'NOT_FOUND'));

      final result = await dataSource.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 19),
      );

      expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      expect((result as Failure).failure, isA<WorkoutNotFoundException>());
    });

    test('Failure - INVALID_DATE → Failure(WorkoutInvalidDateException)', () async {
      when(() => mockChannel.invokeMethod<List<dynamic>>('fetchWorkoutList', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'INVALID_DATE'));

      final result = await dataSource.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 19),
      );

      expect(result, isA<Failure<List<Map<String, dynamic>>>>());
      expect((result as Failure).failure, isA<WorkoutInvalidDateException>());
    });
  });

  // ─────────────────────────────────────────────
  // fetchWorkoutDetails
  // ─────────────────────────────────────────────

  group('fetchWorkoutDetails', () {
    test('Success - 메서드명이 fetchWorkoutDetails로 호출된다', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => mockWorkoutDetails);

      await dataSource.fetchWorkoutDetails(workoutId: 'uuid-1111');

      verify(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any())).called(1);
    });

    test('Success - workoutId가 인자로 전달된다', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => mockWorkoutDetails);

      await dataSource.fetchWorkoutDetails(workoutId: 'uuid-1111');

      final captured = verify(
        () => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', captureAny()),
      ).captured;
      final args = captured.first as Map;
      expect(args['workoutId'], 'uuid-1111');
    });

    test('Success - iOS 응답이 Success(Map)으로 반환된다', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => mockWorkoutDetails);

      final result = await dataSource.fetchWorkoutDetails(workoutId: 'uuid-1111');

      expect(result, isA<Success<Map<String, dynamic>>>());
      final details = (result as Success).value;
      expect(details['stepCountSamples'], isA<List>());
      expect(details['distanceSamples'], isA<List>());
      expect(details['runningSpeedSamples'], isA<List>());
      final stepSamples = details['stepCountSamples'] as List;
      expect(stepSamples.length, 2);
      expect(stepSamples[0]['value'], 130.0);
    });

    test('Success - iOS가 null을 반환하면 Success(빈 Map)을 반환한다', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => null);

      final result = await dataSource.fetchWorkoutDetails(workoutId: 'uuid-1111');

      expect(result, isA<Success<Map<String, dynamic>>>());
      expect((result as Success).value, isEmpty);
    });

    test('Failure - FETCH_FAILED → Failure(WorkoutFetchFailedException)', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'FETCH_FAILED', message: '운동 기록 없음'));

      final result = await dataSource.fetchWorkoutDetails(workoutId: 'not-exist-uuid');

      expect(result, isA<Failure<Map<String, dynamic>>>());
      expect((result as Failure).failure, isA<WorkoutFetchFailedException>());
    });

    test('Failure - NOT_FOUND → Failure(WorkoutNotFoundException)', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'NOT_FOUND'));

      final result = await dataSource.fetchWorkoutDetails(workoutId: 'not-exist-uuid');

      expect(result, isA<Failure<Map<String, dynamic>>>());
      expect((result as Failure).failure, isA<WorkoutNotFoundException>());
    });

    test('Failure - INVALID_ARGS → Failure(WorkoutInvalidArgsException)', () async {
      when(() => mockChannel.invokeMethod<Map<Object?, Object?>>('fetchWorkoutDetails', any()))
          .thenAnswer((_) async => throw PlatformException(code: 'INVALID_ARGS'));

      final result = await dataSource.fetchWorkoutDetails(workoutId: '');

      expect(result, isA<Failure<Map<String, dynamic>>>());
      expect((result as Failure).failure, isA<WorkoutInvalidArgsException>());
    });
  });
}
