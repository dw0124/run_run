import 'package:flutter/material.dart';
import 'package:run_run/presentation/bloc/workout_history_bloc.dart';

class HomePeriodPillGroup extends StatelessWidget {
  const HomePeriodPillGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.brand,
  });

  final WorkoutPeriod value;
  final ValueChanged<WorkoutPeriod> onChanged;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, WorkoutPeriod p) {
      final selected = value == p;
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(p),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? brand : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? brand : Colors.grey[300]!),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill('주', WorkoutPeriod.week),
        const SizedBox(width: 6),
        pill('달', WorkoutPeriod.month),
        const SizedBox(width: 6),
        pill('년', WorkoutPeriod.year),
      ],
    );
  }
}
