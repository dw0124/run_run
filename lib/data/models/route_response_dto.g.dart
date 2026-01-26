// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteResponseDTO _$RouteResponseDTOFromJson(Map<String, dynamic> json) =>
    RouteResponseDTO(
      type: json['type'] as String,
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$RouteResponseDTOToJson(RouteResponseDTO instance) =>
    <String, dynamic>{'type': instance.type, 'features': instance.features};

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
  type: json['type'] as String?,
  geometry:
      json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
  properties:
      json['properties'] == null
          ? null
          : Properties.fromJson(json['properties'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
  'type': instance.type,
  'geometry': instance.geometry,
  'properties': instance.properties,
};

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
  type: json['type'] as String?,
  coordinates: json['coordinates'] as List<dynamic>?,
);

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
  'type': instance.type,
  'coordinates': instance.coordinates,
};

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
  totalDistance: (json['totalDistance'] as num?)?.toInt(),
  totalTime: (json['totalTime'] as num?)?.toInt(),
  index: (json['index'] as num?)?.toInt(),
  pointIndex: (json['pointIndex'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  direction: json['direction'] as String?,
  nearPoiName: json['nearPoiName'] as String?,
  nearPoiX: json['nearPoiX'] as String?,
  nearPoiY: json['nearPoiY'] as String?,
  intersectionName: json['intersectionName'] as String?,
  facilityType: json['facilityType'] as String?,
  facilityName: json['facilityName'] as String?,
  turnType: (json['turnType'] as num?)?.toInt(),
  pointType: json['pointType'] as String?,
);

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'totalDistance': instance.totalDistance,
      'totalTime': instance.totalTime,
      'index': instance.index,
      'pointIndex': instance.pointIndex,
      'name': instance.name,
      'description': instance.description,
      'direction': instance.direction,
      'nearPoiName': instance.nearPoiName,
      'nearPoiX': instance.nearPoiX,
      'nearPoiY': instance.nearPoiY,
      'intersectionName': instance.intersectionName,
      'facilityType': instance.facilityType,
      'facilityName': instance.facilityName,
      'turnType': instance.turnType,
      'pointType': instance.pointType,
    };
