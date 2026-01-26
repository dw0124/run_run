import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:run_run/data/data_sources/geolocator_data_source.dart';
import 'package:run_run/data/data_sources/pedometer_data_source.dart';
import 'package:run_run/data/data_sources/tmap_routes_data_source.dart';
import 'package:run_run/data/data_sources/workout_data_source.dart';
import 'package:run_run/data/repositories/location_tracking_repo_impl.dart';
import 'package:run_run/data/repositories/pedometer_repo_impl.dart';
import 'package:run_run/data/repositories/route_repo_impl.dart';
import 'package:run_run/data/repositories/workout_repo_impl.dart';
import 'package:run_run/domain/location_filter.dart';
import 'package:run_run/domain/usecases/map_use_case.dart';
import 'package:run_run/domain/usecases/pedometer_use_case.dart';
import 'package:run_run/domain/usecases/workout_use_case.dart';
import 'package:run_run/presentation/bloc/location_bloc.dart';
import 'package:run_run/domain/usecases/location_tracking_use_case.dart';
import 'package:run_run/presentation/bloc/map_bloc.dart';
import 'package:run_run/presentation/bloc/pedometer_bloc.dart';
import 'package:run_run/presentation/bloc/workout_bloc.dart';
import 'package:run_run/presentation/page/map_page.dart';
import 'package:run_run/presentation/page/paint_page.dart';
import 'package:geolocator/geolocator.dart';

import 'presentation/page/test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // API_KEY 등을 위한 환경변수 로드
  await dotenv.load(fileName: 'assets/config/.env');

  // Geolocator 사용을 위한 위치 권한 요청
  LocationPermission permission = await Geolocator.requestPermission();

  // NaverMap 초기화
  final naverMapClientId = dotenv.get("NAVER_CLIENT_ID");

  await FlutterNaverMap().init(
      clientId: naverMapClientId,
      onAuthFailed: (ex) {
        switch (ex) {
          case NQuotaExceededException(:final message):
            print("사용량 초과 (message: $message)");
            break;
          case NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException():
            print("인증 실패: $ex");
            break;
        }
      }
  );

  // Location 의존성 주입
  final dataSource = GeoLocatorDataSource();
  final repository = LocationTrackingRepoImpl(dataSource: dataSource);

  final LocationFilter filter = LocationFilter();

  final locationInitUseCase   = InitLocationTrackingUseCase(repository, filter);
  final locationStartUseCase  = StartLocationTrackingUseCase(repository, filter);
  final locationPauseUseCase  = PauseLocationTrackingUseCase(repository);
  final locationCancelUseCase = CancelLocationTrackingUseCase(repository);

  final routeDataSource = TmapRoutesDataSource();
  final routeRepo = RouteRepoImpl(dataSource: routeDataSource);
  final requestRouteUseCase = RequestRouteUseCase(routeRepo);

  // Pedometer 의존성 주입
  final pedometerDataSource = PedometerDataSource();
  final pedometerRepo = PedometerRepoImpl(dataSource: pedometerDataSource);

  final pedometerInitUseCase = InitPedometerUseCase(pedometerRepo);
  final pedometerStartUseCase = StartPedometerUseCase(pedometerRepo);
  final pedometerPauseUseCase = PausePedometerUseCase(pedometerRepo);
  final pedometerCancelUseCase = CancelPedometerUseCase(pedometerRepo);

  // Workout 의존성 주입
  final workoutDataSource = HealthKitWorkoutDataSource();
  final workoutRepo = WorkoutRepoImpl(dataSource: workoutDataSource);

  final workoutUseCase = WorkoutUseCase(workoutRepo, locationInitUseCase, pedometerInitUseCase);

  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LocationBloc(
              initLocationTrackingUseCase: locationInitUseCase,
              startLocationTrackingUseCase: locationStartUseCase,
              pauseLocationTrackingUseCase: locationPauseUseCase,
              cancelLocationTrackingUseCase: locationCancelUseCase,
            )
          ),
          BlocProvider(
            create: (_) => MapBloc(
              requestRouteUseCase: requestRouteUseCase
            )
          ),
          BlocProvider(
            create: (_) => PedometerBloc(
              initPedometerUseCase: pedometerInitUseCase,
              startPedometerUseCase: pedometerStartUseCase,
              pausePedometerUseCase: pedometerPauseUseCase,
              cancelPedometerUseCase: pedometerCancelUseCase,
            )
          ),
          BlocProvider(
              create: (_) => WorkoutBloc(workoutUseCase: workoutUseCase)
          ),

        ],
        child: const MaterialApp(home: MapPage()),
      )
  );

  // runApp(MaterialApp(home: TestPage()));
}