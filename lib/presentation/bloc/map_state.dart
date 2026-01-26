part of 'map_bloc.dart';

class MapState extends Equatable {

  const MapState({
    this.coordinates = const [],
    this.locations = const [],
    this.nLatLngs = const [],
    this.isTracking = false,
  });

  /// 경로 api의 경로(좌표) 리스트
  final List<List<double>> coordinates;

  /// 사용자 위치 리스트
  final List<List<Location>> locations;

  /// 지도에 경로 오버레이를 위한 좌표 리스트
  final List<List<NLatLng>> nLatLngs;

  /// 위치 스트림 플래그
  final bool isTracking;

  MapState copyWith({
    List<List<double>>? coordinates,
    List<List<Location>>? locations,
    List<List<NLatLng>>? nLatLngs,
    bool? isTracking,
  }) {
    return MapState(
      coordinates: coordinates ?? this.coordinates,
      locations: locations ?? this.locations,
      nLatLngs: nLatLngs ?? this.nLatLngs,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [coordinates, locations, nLatLngs, isTracking];
}