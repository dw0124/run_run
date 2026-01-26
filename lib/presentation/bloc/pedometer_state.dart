part of 'pedometer_bloc.dart';

enum PedometerStatus {
  initial,
  tracking,
  paused,
  canceled,
  error,
}

class PedometerState extends Equatable {

  const PedometerState({
    this.status = PedometerStatus.initial,
    this.pedometerList = const [],
  });

  final PedometerStatus status;
  final List<Pedometer> pedometerList;

  PedometerState copyWith({
    PedometerStatus? status,
    List<Pedometer>? pedometerList,
  }) {
    return PedometerState(
      status: status ?? this.status,
      pedometerList: pedometerList ?? this.pedometerList,
    );
  }

  @override
  List<Object?> get props => [status, pedometerList];
}

// class PedometerState1 extends Equatable {
//   PedometerState1();
//
//   final double previousDistance = 0;  // 이전까지 완료된 누적 거리
//   final double currentDistance = 0;   // 현재 스트림으로 들어오고 있는 거리
//
//   double get totalDistance => previousDistance + currentDistance; // UI로 표시될 총 거리
//
//   final double? currentPace;    // Pedometer의 currentPace
//   final double? currentCadence; // Pedometer의 currentCadence
//
//   final double? averageActivePace;
//
//   @override
//   List<Object?> get props => [];
//
//
// }