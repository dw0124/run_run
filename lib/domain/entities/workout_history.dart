class WorkoutHistory {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double duration;
  final double totalDistance;
  final double averageRunningSpeed;
  final double totalEnergyBurned;

  const WorkoutHistory({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalDistance,
    required this.averageRunningSpeed,
    required this.totalEnergyBurned,
  });
}
