import 'package:flutter/material.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:run_run/counter_timer.dart';
import 'package:run_run/presentation/bloc/location_bloc.dart';
import 'package:run_run/presentation/bloc/map_bloc.dart';
import 'package:run_run/presentation/bloc/pedometer_bloc.dart';
import 'package:run_run/presentation/bloc/workout_bloc.dart';
import 'package:run_run/presentation/page/test_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  late NaverMapController _mapController;

  final CounterTimer _counterTimer = CounterTimer();
  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$count'),
      ),
      body: MultiBlocListener(
        listeners: [

          // Location Status Event - Map Status Event
          BlocListener<WorkoutBloc, WorkoutState>(
            listenWhen: (previous, current) {
              return previous.status != current.status;
            },
            listener: (context, workoutState) {
              if(workoutState.status == WorkoutStatus.running) {
                context.read<MapBloc>().add(MapTrackingStatusChangedEvent(true));
              } else if(workoutState.status == WorkoutStatus.paused) {
                context.read<MapBloc>().add(MapTrackingStatusChangedEvent(false));
              }
            }
          ),

          // Location Added - MapBloc MapLocationAddedEvent
          BlocListener<LocationBloc, LocationState>(
            listenWhen: (previous, current) {
              return current.status == LocationStatus.tracking
                  && previous.location != current.location;
            },
            listener: (context, locationState) {
              final location = locationState.location;
              if(location != null) {
                context.read<MapBloc>().add(MapLocationAddedEvent(location));
              }
            }
          ),

          // 티맵 API - 경로 표시
          BlocListener<MapBloc, MapState>(
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
                _mapController.addOverlay(routeOverlay);
              }
          ),

          // 유저 경로 표시
          BlocListener<MapBloc, MapState>(
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

              _mapController.addOverlay(userRouteOverlay);
            }
          ),
        ],
        child: Scaffold(
          floatingActionButton: ElevatedButton(onPressed: () {
            final mode = NLocationTrackingMode.follow;
            _mapController.setLocationTrackingMode(mode);
          }, child: Text('Follow')),
          appBar: AppBar(
            backgroundColor: Colors.transparent.withValues(alpha: 0),
          ),
          body: SafeArea(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                  children: [
                    NaverMap(
                      onMapReady: (controller) async {
                        _mapController = controller;
                        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                          target: NLatLng(37.328678719776455, -122.02112851619876),
                        );



                        _mapController.updateCamera(cameraUpdate);

                        final mode = NLocationTrackingMode.follow;
                        _mapController.setLocationTrackingMode(mode);
                      },

                      onMapTapped: (point, latLng) async {
                        final lat = latLng.latitude;
                        final lng = latLng.longitude;

                        // 카메라 업데이트
                        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                          target: NLatLng(lat, lng),
                        );

                        _mapController.updateCamera(cameraUpdate);
                      },
                    ),


                    Row(
                      children: [
                        ElevatedButton(onPressed: () {
                          context.read<WorkoutBloc>().add(WorkoutStartEvent());
                          // context.read<LocationBloc>().add(LocationTrackingStartEvent());
                          // context.read<PedometerBloc>().add(PedometerStartEvent());
                        }, child: Text('Tracking Start')),
                        ElevatedButton(onPressed: () {
                          context.read<WorkoutBloc>().add(WorkoutPauseEvent());
                          // context.read<LocationBloc>().add(LocationTrackingPauseEvent());
                          // context.read<PedometerBloc>().add(PedometerPauseEvent());
                        }, child: Text('Tracking Pause')),
                        IconButton(onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return const TestPage();
                            },
                          );
                        }, icon: Icon(Icons.insert_emoticon_rounded))
                      ],
                    )

                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}