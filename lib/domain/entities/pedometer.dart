class Pedometer {
  final String startDate;
  final  String endDate;

  final double numberOfSteps;
  final double? distance;

  final double? floorsAscended;
  final double? floorsDescended;

  final double? currentPace;
  final double? currentCadence;
  final double? averageActivePace;

  Pedometer({
    required this.startDate,
    required this.endDate,
    required this.numberOfSteps,
    this.distance,
    this.floorsAscended,
    this.floorsDescended,
    this.currentPace,
    this.currentCadence,
    this.averageActivePace,
  });

  @override
  String toString() {
    return 'Pedometer('
        'startDate: $startDate, '
        'endDate: $endDate, '
        'numberOfSteps: $numberOfSteps, '
        'distance: $distance, '
        'floorsAscended: $floorsAscended, '
        'floorsDescended: $floorsDescended, '
        'currentPace: $currentPace, '
        'currentCadence: $currentCadence, '
        'averageActivePace: $averageActivePace'
        ')';
  }
}