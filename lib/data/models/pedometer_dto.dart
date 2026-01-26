import 'package:json_annotation/json_annotation.dart';

part 'pedometer_dto.g.dart';

/// iOS - PedometerData DTO
@JsonSerializable()
class PedometerDTO {
  final String startDate;
  final String endDate;

  final double numberOfSteps;
  final double? distance;

  final double? floorsAscended;
  final double? floorsDescended;

  final double? currentPace;
  final double? currentCadence;
  final double? averageActivePace;

  PedometerDTO({
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

  factory PedometerDTO.fromJson(Map<String, dynamic> json) => _$PedometerDTOFromJson(json);

  Map<String, dynamic> toJson() => _$PedometerDTOToJson(this);
}