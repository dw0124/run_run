import 'package:json_annotation/json_annotation.dart';

part 'route_response_dto.g.dart';

@JsonSerializable()
class RouteResponseDTO {
  final String type;
  final List<Feature>? features;

  const RouteResponseDTO({
    required this.type,
    this.features
  });

  factory RouteResponseDTO.fromJson(Map<String, dynamic> json) => _$RouteResponseDTOFromJson(json);
  Map<String, dynamic> toJson() => _$RouteResponseDTOToJson(this);
}

@JsonSerializable()
class Feature {
  final String? type;
  final Geometry? geometry;
  final Properties? properties;

  const Feature({
    this.type,
    this.geometry,
    this.properties
  });

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}

@JsonSerializable()
class Geometry {
  final String? type;    // Point, LineString 둘 중 하나
  final List<dynamic>? coordinates;  //  type에 따라서 배열, 이중배열

  const Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);
  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}

@JsonSerializable()
class Properties {
  final int? totalDistance;
  final int? totalTime;
  final int? index;
  final int? pointIndex;
  final String? name;
  final String? description;
  final String? direction;
  final String? nearPoiName;
  final String? nearPoiX;
  final String? nearPoiY;
  final String? intersectionName;
  final String? facilityType;
  final String? facilityName;
  final int? turnType;
  final String? pointType;

  const Properties({
    this.totalDistance,
    this.totalTime,
    this.index,
    this.pointIndex,
    this.name,
    this.description,
    this.direction,
    this.nearPoiName,
    this.nearPoiX,
    this.nearPoiY,
    this.intersectionName,
    this.facilityType,
    this.facilityName,
    this.turnType,
    this.pointType
  });

  factory Properties.fromJson(Map<String, dynamic> json) => _$PropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}