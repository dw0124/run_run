import 'dart:async';

class CounterTimer {
  int _count = 0;
  Timer? _timer;

  int get count => _count;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _count++;
      print("count: $_count");
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
