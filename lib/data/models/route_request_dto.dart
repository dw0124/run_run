class RouteRequestDTO {
  final String type;
  final List<Feature> features;

  const RouteRequestDTO({
    required this.type,
    required this.features
  });
}

class Feature {
  final String type;
  final Geometry geometry;
  final Properties properties;

  const Feature({
    required this.type,
    required this.geometry,
    required this.properties
  });
}

class Geometry {
  final String type;    // Point, LineString 둘 중 하나
  final List<dynamic> coordinates;  //  type에 따라서 배열, 이중배열

  const Geometry({
    required this.type,
    required this.coordinates,
  });
}

class Properties {
  final int totalDistance;
  final int totalTime;
  final int index;
  final int pointIndex;
  final String name;
  final String description;
  final String direction;
  final String nearPoiName;
  final String nearPoiX;
  final String nearPoiY;
  final String intersectionName;
  final String facilityType;
  final String facilityName;
  final int turnType;
  final String pointType;

  const Properties({
    required this.totalDistance,
    required this.totalTime,
    required this.index,
    required this.pointIndex,
    required this.name,
    required this.description,
    required this.direction,
    required this.nearPoiName,
    required this.nearPoiX,
    required this.nearPoiY,
    required this.intersectionName,
    required this.facilityType,
    required this.facilityName,
    required this.turnType,
    required this.pointType
  });
}

/*
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [
      126.99693337276166,
      37.56150837538353
    ]
  },
  "properties": {
    "totalDistance": 197,
    "totalTime": 177,
    "index": 0,
    "pointIndex": 0,
    "name": "",
    "description": "19m 이동",
    "direction": "",
    "nearPoiName": "",
    "nearPoiX": "0.0",
    "nearPoiY": "0.0",
    "intersectionName": "",
    "facilityType": "11",
    "facilityName": "",
    "turnType": 200,
    "pointType": "SP"
  }
}
*/