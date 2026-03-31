class WorkoutSample {
  final DateTime startDate;
  final DateTime endDate;
  final double value;

  const WorkoutSample({
    required this.startDate,
    required this.endDate,
    required this.value,
  });
}

class WorkoutDetailHistory {
  final String workoutId;
  final List<WorkoutSample> stepCountSamples;
  final List<WorkoutSample> distanceSamples;
  final List<WorkoutSample> runningSpeedSamples;

  const WorkoutDetailHistory({
    required this.workoutId,
    required this.stepCountSamples,
    required this.distanceSamples,
    required this.runningSpeedSamples,
  });
}
