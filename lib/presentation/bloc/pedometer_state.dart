part of 'pedometer_bloc.dart';

class PedometerState extends Equatable {
  const PedometerState({
    this.totalSteps = 0,
    this.totalDistance = 0,
    this.currentPace,
    this.currentCadence,
  });

  final int totalSteps;         // 누적 걸음수
  final double totalDistance;   // 누적 거리
  final double? currentPace;    // Pedometer의 currentPace
  final double? currentCadence; // Pedometer의 currentCadence

  PedometerState copyWith({
    int? totalSteps,
    double? totalDistance,
    double? currentPace,
    double? currentCadence,
  }) {
    return PedometerState(
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistance: totalDistance ?? this.totalDistance,
      currentPace: currentPace ?? this.currentPace,
      currentCadence: currentCadence ?? this.currentCadence,
    );
  }

  @override
  List<Object?> get props => [
    totalSteps,
    totalDistance,
    currentPace,
    currentCadence
  ];
}