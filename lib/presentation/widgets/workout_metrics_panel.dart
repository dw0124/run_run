import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_run/presentation/bloc/pedometer_bloc.dart';
import 'package:run_run/presentation/bloc/workout_bloc.dart';

import 'package:run_run/shared/utils/time_formatter.dart';
import 'package:run_run/shared/utils/workout_formatter.dart';

class WorkoutMetricsPanel extends StatelessWidget {
  const WorkoutMetricsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 시간
        Expanded(
          flex: 6,
          child: _TimeMetric(),
        ),

        // 거리 / 평균 페이스
        Expanded(
          flex: 4,
          child: _DistanceAndAveragePaceMetric(),
        ),

        // 현재 페이스 / 현재 케이던스
        Expanded(
          flex: 4,
          child: _CurrentPaceAndCadenceMetric(),
        ),
      ],
    );
  }
}

// 시간
class _TimeMetric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: BlocSelector<WorkoutBloc, WorkoutState, int>(
        selector: (state) => state.elapsedSeconds,
        builder: (context, seconds) {
          return Center(
            child: Text(
              TimeFormatter.formatDuration(seconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

// 거리 / 평균 페이스
class _DistanceAndAveragePaceMetric extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final distance = context.select((PedometerBloc bloc) => bloc.state.totalDistance);
    final seconds = context.select((WorkoutBloc bloc) => bloc.state.elapsedSeconds);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 거리
          Expanded(
            child: _MetricItem(
              label: '거리',
              value: WorkoutFormatter.formatDistance(distance),
            ),
          ),

          // 구분선
          Container(
            width: 1,
            color: Colors.grey[300],
          ),

          // 평균 페이스
          Expanded(
            child: _MetricItem(
              label: '평균 페이스',
              value: WorkoutFormatter.formatAveragePace(seconds, distance),
            ),
          ),
        ],
      ),
    );
  }
}

// 현재 페이스 / 현재 케이던스
class _CurrentPaceAndCadenceMetric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isActive = context.select(
          (WorkoutBloc bloc) => bloc.state.status == WorkoutStatus.running,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // 현재 페이스
          Expanded(
            child: BlocSelector<PedometerBloc, PedometerState, double?>(
              selector: (state) => state.currentPace,
              builder: (context, pace) {
                return _MetricItem(
                  label: '현재 페이스',
                  value: WorkoutFormatter.formatCurrentPace(pace),
                  isActive: isActive,
                );
              }
            )
          ),

          // 구분선
          Container(
            width: 1,
            color: Colors.grey[300],
          ),

          // 현재 케이던스
          Expanded(
            child: BlocSelector<PedometerBloc, PedometerState, double?>(
              selector: (state) => state.currentCadence,
              builder: (context, cadence) {
                return _MetricItem(
                  label: '현재 케이던스',
                  value: (cadence != null) ? '${cadence.toInt()} spm' : '-- spm',
                  isActive: isActive,
                );
              },
            )
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;

  const _MetricItem({
    required this.label,
    required this.value,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}