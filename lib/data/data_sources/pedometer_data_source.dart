import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:run_run/data/models/pedometer_dto.dart';

class PedometerDataSource {

  PedometerDataSource();

  final EventChannel _eventChannel = EventChannel('com.example.runRun/pedometer_channel');

  final StreamController<PedometerDTO> _controller = StreamController<PedometerDTO>.broadcast();
  StreamSubscription<dynamic>? _subscription;

  Stream<PedometerDTO> get pedometerDataDTOStream => _controller.stream;

  Future<void> start() async {
    await _subscription?.cancel();

    _subscription = _eventChannel
        .receiveBroadcastStream()
        .listen((dynamic event) {
          if(_controller.isClosed) return;

          if (event != null && event is String) {
            final decodedJson = jsonDecode(event) as Map<String, dynamic>;
            final dto = PedometerDTO.fromJson(decodedJson);
            _controller.add(dto);
          } else {
            // 데이터가 null 이거나 타입이 다를 경우
            print('PedometerDataSource: Invalid or null data received');
          }
        }, onError: (dynamic error) {
          print('PedometerDataSource Error: $error');
        });
  }

  Future<void> cancel() async {
    await _subscription?.cancel();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}