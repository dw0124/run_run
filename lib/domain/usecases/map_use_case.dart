import 'package:run_run/data/repositories/route_repo_impl.dart';
import 'package:run_run/domain/entities/route.dart';

class RequestRouteUseCase {
  RequestRouteUseCase(this._repo);

  final RouteRepoImpl _repo;

  Future<List<List<double>>> call(Route route) async {
    final coordinates = await _repo.requestRoute(route);
    return coordinates;
  }
}