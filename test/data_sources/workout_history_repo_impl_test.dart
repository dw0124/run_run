import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:run_run/data/data_sources/workout_history_data_source.dart';
import 'package:run_run/data/errors/workout_history_exception.dart';
import 'package:run_run/data/repositories/workout_history_repo_impl.dart';
import 'package:run_run/domain/entities/workout_detail_history.dart';
import 'package:run_run/domain/entities/workout_history.dart';
import 'package:run_run/domain/errors/workout_history_failure.dart';
import 'package:run_run/shared/result.dart';

class MockWorkoutHistoryDataSource extends Mock implements WorkoutHistoryDataSource {}

final List<Map<String, dynamic>> mockWorkoutListRaw = [
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

final Map<String, dynamic> mockWorkoutDetailsRaw = {
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
  late WorkoutHistoryRepositoryImpl repository;
  late MockWorkoutHistoryDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWorkoutHistoryDataSource();
    repository = WorkoutHistoryRepositoryImpl(mockDataSource);
  });

  // ─────────────────────────────────────────────
  // fetchWorkoutList
  // ─────────────────────────────────────────────

  group('fetchWorkoutList', () {
    test('Success - List<Map>이 List<WorkoutHistory>로 매핑된다', () async {
      when(() => mockDataSource.fetchWorkoutList(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Success(mockWorkoutListRaw));

      final result = await repository.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      expect(result, isA<Success<List<WorkoutHistory>>>());
      final workouts = (result as Success).value;
      expect(workouts.length, 2);
      expect(workouts[0].id, 'uuid-1111');
      expect(workouts[0].totalDistance, 5000.0);
      expect(workouts[1].id, 'uuid-2222');
    });

    test('Success - 빈 리스트가 반환되면 Success(빈 리스트)를 반환한다', () async {
      when(() => mockDataSource.fetchWorkoutList(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Success([]));

      final result = await repository.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      expect(result, isA<Success<List<WorkoutHistory>>>());
      expect((result as Success).value, isEmpty);
    });

    test('Failure - WorkoutNotFoundException → WorkoutHistoryNotFoundFailure', () async {
      when(() => mockDataSource.fetchWorkoutList(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Failure(const WorkoutNotFoundException()));

      final result = await repository.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      expect(result, isA<Failure<List<WorkoutHistory>>>());
      expect((result as Failure).failure, isA<WorkoutHistoryNotFoundFailure>());
    });

    test('Failure - WorkoutInvalidDateException → WorkoutHistoryInvalidDateFailure', () async {
      when(() => mockDataSource.fetchWorkoutList(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Failure(const WorkoutInvalidDateException()));

      final result = await repository.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      expect(result, isA<Failure<List<WorkoutHistory>>>());
      expect((result as Failure).failure, isA<WorkoutHistoryInvalidDateFailure>());
    });

    test('Failure - WorkoutFetchFailedException → WorkoutHistoryFetchFailedFailure', () async {
      when(() => mockDataSource.fetchWorkoutList(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => Failure(const WorkoutFetchFailedException('서버 오류')));

      final result = await repository.fetchWorkoutList(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 3, 31),
      );

      expect(result, isA<Failure<List<WorkoutHistory>>>());
      expect((result as Failure).failure, isA<WorkoutHistoryFetchFailedFailure>());
    });
  });

  // ─────────────────────────────────────────────
  // fetchWorkoutDetails
  // ─────────────────────────────────────────────

  group('fetchWorkoutDetails', () {
    test('Success - Map이 WorkoutDetailHistory로 매핑된다', () async {
      when(() => mockDataSource.fetchWorkoutDetails(workoutId: any(named: 'workoutId')))
          .thenAnswer((_) async => Success(mockWorkoutDetailsRaw));

      final result = await repository.fetchWorkoutDetails(workoutId: 'uuid-1111');

      expect(result, isA<Success<WorkoutDetailHistory>>());
      final details = (result as Success).value;
      expect(details.workoutId, 'uuid-1111');
      expect(details.stepCountSamples.length, 2);
      expect(details.stepCountSamples[0].value, 130.0);
      expect(details.distanceSamples.length, 2);
      expect(details.runningSpeedSamples.length, 2);
    });

    test('Success - 빈 Map이 반환되면 샘플 리스트가 모두 비어있다', () async {
      when(() => mockDataSource.fetchWorkoutDetails(workoutId: any(named: 'workoutId')))
          .thenAnswer((_) async => Success({}));

      final result = await repository.fetchWorkoutDetails(workoutId: 'uuid-1111');

      expect(result, isA<Success<WorkoutDetailHistory>>());
      final details = (result as Success).value;
      expect(details.stepCountSamples, isEmpty);
      expect(details.distanceSamples, isEmpty);
      expect(details.runningSpeedSamples, isEmpty);
    });

    test('Failure - WorkoutNotFoundException → WorkoutHistoryNotFoundFailure', () async {
      when(() => mockDataSource.fetchWorkoutDetails(workoutId: any(named: 'workoutId')))
          .thenAnswer((_) async => Failure(const WorkoutNotFoundException()));

      final result = await repository.fetchWorkoutDetails(workoutId: 'not-exist');

      expect(result, isA<Failure<WorkoutDetailHistory>>());
      expect((result as Failure).failure, isA<WorkoutHistoryNotFoundFailure>());
    });

    test('Failure - WorkoutInvalidArgsException → WorkoutHistoryInvalidArgsFailure', () async {
      when(() => mockDataSource.fetchWorkoutDetails(workoutId: any(named: 'workoutId')))
          .thenAnswer((_) async => Failure(const WorkoutInvalidArgsException()));

      final result = await repository.fetchWorkoutDetails(workoutId: '');

      expect(result, isA<Failure<WorkoutDetailHistory>>());
      expect((result as Failure).failure, isA<WorkoutHistoryInvalidArgsFailure>());
    });

    test('Failure - WorkoutFetchFailedException → WorkoutHistoryFetchFailedFailure', () async {
      when(() => mockDataSource.fetchWorkoutDetails(workoutId: any(named: 'workoutId')))
          .thenAnswer((_) async => Failure(const WorkoutFetchFailedException('조회 실패')));

      final result = await repository.fetchWorkoutDetails(workoutId: 'uuid-1111');

      expect(result, isA<Failure<WorkoutDetailHistory>>());
      expect((result as Failure).failure, isA<WorkoutHistoryFetchFailedFailure>());
    });
  });
}
