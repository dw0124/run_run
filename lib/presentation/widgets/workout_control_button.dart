import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_run/presentation/bloc/workout_bloc.dart';

class WorkoutControlButton extends StatelessWidget {

  const WorkoutControlButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: BlocSelector<WorkoutBloc, WorkoutState, WorkoutStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          return status == WorkoutStatus.running
              ? _buildActiveButtons(context)
              : _buildPausedButtons(context);
        },
      ),
    );
  }

  // 러닝 중: 정지 버튼만
  Widget _buildActiveButtons(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.read<WorkoutBloc>().add(WorkoutPauseEvent()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '정지',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 정지 중: 재개/종료 버튼
  Widget _buildPausedButtons(BuildContext context) {
    return Row(
      children: [
        // 재개 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.read<WorkoutBloc>().add(WorkoutStartEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '재개',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        SizedBox(width: 16),

        // 종료 버튼
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.read<WorkoutBloc>().add(WorkoutCancelEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '종료',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}