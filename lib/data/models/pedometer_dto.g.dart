// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedometer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedometerDTO _$PedometerDTOFromJson(Map<String, dynamic> json) => PedometerDTO(
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String,
  numberOfSteps: (json['numberOfSteps'] as num).toDouble(),
  distance: (json['distance'] as num?)?.toDouble(),
  floorsAscended: (json['floorsAscended'] as num?)?.toDouble(),
  floorsDescended: (json['floorsDescended'] as num?)?.toDouble(),
  currentPace: (json['currentPace'] as num?)?.toDouble(),
  currentCadence: (json['currentCadence'] as num?)?.toDouble(),
  averageActivePace: (json['averageActivePace'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PedometerDTOToJson(PedometerDTO instance) =>
    <String, dynamic>{
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'numberOfSteps': instance.numberOfSteps,
      'distance': instance.distance,
      'floorsAscended': instance.floorsAscended,
      'floorsDescended': instance.floorsDescended,
      'currentPace': instance.currentPace,
      'currentCadence': instance.currentCadence,
      'averageActivePace': instance.averageActivePace,
    };
