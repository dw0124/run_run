import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_run/presentation/bloc/workout_bloc.dart';
import 'package:run_run/presentation/bloc/map_bloc.dart';
import 'package:run_run/presentation/bloc/location_bloc.dart';

import 'package:run_run/presentation/widgets/workout_control_button.dart';
import 'package:run_run/presentation/widgets/workout_map.dart';
import 'package:run_run/presentation/widgets/workout_metrics_panel.dart';


class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutState();
}

class _WorkoutState extends State<WorkoutPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          _workoutStatusListener(),     // Workout Status 변화 감지 - MapBloc 전달
          _locationTrackingListener(),  // 위치 업데이트 감지 -> MapBloc 전달 (Location Added - MapBloc MapLocationAddedEvent)
        ],
        child: SafeArea(
            child: Column(
              children: [
                // 지도
                Expanded(
                  flex: 2,
                  child: WorkoutMap(),
                ),

                // 정보 섹션
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // 시간
                      Expanded(
                          flex: 3,
                          child: WorkoutMetricsPanel()
                      ),

                      // 조작 버튼
                      Expanded(
                        flex: 1,
                        child: WorkoutControlButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

// =========================================================
// MARK: - Workout Bloc Listeners
// =========================================================

extension _WorkoutListeners on _WorkoutState {
  // 운동 상태 변화 감지 (Map Tracking On/Off)
  BlocListener<WorkoutBloc, WorkoutState> _workoutStatusListener() {
    return BlocListener<WorkoutBloc, WorkoutState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },
        listener: (context, workoutState) {
          if(workoutState.status == WorkoutStatus.running) {
            context.read<MapBloc>().add(MapTrackingStatusChangedEvent(true));
          } else if(workoutState.status == WorkoutStatus.paused) {
            context.read<MapBloc>().add(MapTrackingStatusChangedEvent(false));
          }
        }
    );
  }

  // 위치 업데이트 감지 -> MapBloc 전달
  BlocListener<LocationBloc, LocationState> _locationTrackingListener() {
    return BlocListener<LocationBloc, LocationState>(
        listenWhen: (previous, current) {
          return current.status == LocationStatus.tracking
              && previous.location != current.location;
        },
        listener: (context, locationState) {
          final location = locationState.location;
          if(location != null) {
            context.read<MapBloc>().add(MapLocationAddedEvent(location));
          }
        }
    );
  }
}