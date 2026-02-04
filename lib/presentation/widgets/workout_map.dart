import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:run_run/presentation/bloc/map_bloc.dart';

class WorkoutMap extends StatefulWidget {
  const WorkoutMap({super.key});

  @override
  State<WorkoutMap> createState() => _WorkoutMapState();
}

class _WorkoutMapState extends State<WorkoutMap> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        _mapRouteOverlayListener(),   // 티맵 API - 경로 표시
        _userPathOverlayListener(),   // 유저 경로 표시
      ],
      child: NaverMap(
        onMapReady: (controller) {
          _mapController = controller;

          final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(37.328678719776455, -122.02112851619876),
          );

          _mapController?.updateCamera(cameraUpdate);
          _mapController?.setLocationTrackingMode(NLocationTrackingMode.follow);
        }
      ),
    );
  }
}


extension _WorkoutMapListeners on _WorkoutMapState {
  // 지도 API 경로 표시 (NPathOverlay)
  BlocListener<MapBloc, MapState> _mapRouteOverlayListener() {
    return BlocListener<MapBloc, MapState>(
        listenWhen: ((previous, current) {
          return previous.coordinates != current.coordinates && current.coordinates.isNotEmpty;
        }),
        listener: (context, state) {
          final routes = state.coordinates
              .where((coordinates) => coordinates.length >= 2)
              .map((coordinates) {
                final lng = coordinates[0];
                final lat = coordinates[1];
                return NLatLng(lat, lng);
              })
              .toList();

          final routeOverlay = NPathOverlay(id: 'Routes', coords: routes);
          _mapController?.addOverlay(routeOverlay);
        }
    );
  }

  // 유저 실제 이동 경로 표시 (NMultipartPathOverlay)
  BlocListener<MapBloc, MapState> _userPathOverlayListener() {
    return BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          final paths = state.nLatLngs
              .where((nLatLngs) => nLatLngs.isNotEmpty)
              .map((nLatLngs) {
                return NMultipartPath(
                    coords: nLatLngs,
                    outlineColor: Colors.transparent,
                    color: Colors.green
                );
              })
              .toList();

          final userRouteOverlay = NMultipartPathOverlay(id: "UserPath", paths: paths);

          _mapController?.addOverlay(userRouteOverlay);
        }
    );
  }
}