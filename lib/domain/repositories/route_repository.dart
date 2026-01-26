import 'package:run_run/domain/entities/route.dart';

abstract class RouteRepository {
  Future<List<List<double>>> requestRoute(Route route);
}