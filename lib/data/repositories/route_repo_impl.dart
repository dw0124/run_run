import 'package:run_run/data/data_sources/tmap_routes_data_source.dart';
import 'package:run_run/data/models/route_response_dto.dart';
import 'package:run_run/domain/entities/route.dart';
import 'package:run_run/domain/repositories/route_repository.dart';

class RouteRepoImpl implements RouteRepository {

  RouteRepoImpl({required RouteDataSource dataSource}) : _dataSource = dataSource;

  final RouteDataSource _dataSource;

  @override
  Future<List<List<double>>> requestRoute(Route route) async {
    final response = await _dataSource.requestRoute(route);

    final responseDTO = RouteResponseDTO.fromJson(response);

    if(responseDTO.features == null) {
      return const [];
    }

    final features = responseDTO.features!;

    final coordinates = features
        .whereType<Feature>()
        .map((feature) => feature.geometry)
        .whereType<Geometry>()
        .map((geometry) => geometry.coordinates)
        .whereType<List<dynamic>>()
        .expand((coordinates) {
          if (coordinates.isEmpty) return const <List<double>>[];

          final first = coordinates.first;
          if (first is List) {
            // List<List<double>> 구조로 캐스팅
            return coordinates
                .map((coord) => (coord as List).cast<double>())
                .toList();
          } else {
            // List<double> -> 이중 배열 구조
            return [coordinates.cast<double>()];
          }
        })
        .toList();

    return coordinates;
  }

}