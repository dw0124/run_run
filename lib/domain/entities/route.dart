import 'package:equatable/equatable.dart';

enum SearchOption {
  recommended(0, '추천'),
  recommendedPriorityRoads(4, '추천+대로우선'),
  shortest(10, '최단'),
  shortestNoStairs(30, '최단거리+계단제외');

  final int code;
  final String description;

  const SearchOption(this.code, this.description);
}

class LatLng {
  final double lat;
  final double lng;

  const LatLng({required this.lat, required this.lng});


}

class Route extends Equatable {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final List<String> passList;
  final SearchOption searchOption;
  final List<List<double>>? coordinates;

  const Route({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    this.searchOption = SearchOption.recommended,
    required this.passList,
    this.coordinates,
  });

  @override
  List<Object?> get props => [startX, startY, endX, endY, passList, coordinates];
}