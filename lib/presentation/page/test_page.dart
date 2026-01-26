import 'dart:async';
import 'dart:math'; // 랜덤 숫자 생성을 위해 추가
import 'package:flutter/material.dart';
import 'package:run_run/shared/testChannel.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TestChannel testChannel = TestChannel();
  Timer? _timer;
  int _count = 0;
  final Random _random = Random();

  // 10분 동안 5초 간격으로 실행될 최대 횟수 (10분 = 600초 / 5초 = 120회)
  final int _maxTicks = (5 * 60) ~/ 5;

  void _startAutoAdd() {
    _timer?.cancel();
    _count = 0;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_count >= _maxTicks) {
        _stopAutoAndSave();
        return;
      }

      setState(() { _count++; });

      // 1. 랜덤 데이터 생성
      double steps = (_random.nextInt(41) + 80).toDouble();      // 80~120 steps
      double distance = (_random.nextInt(11) + 10).toDouble();   // 10~20 meters
      double speed = distance / 5;                               // meters/second (페이스 차트용)
      double energy = (_random.nextInt(3) + 2).toDouble();       // 2~4 kcal

      // 2. 플랫폼 채널로 각각 전송
      await testChannel.addSample(value: steps, type: 'step');
      await testChannel.addSample(value: distance, type: 'distance');
      await testChannel.addSample(value: speed, type: 'speed');
      await testChannel.addSample(value: energy, type: 'energy');
    });
  }

  // 타이머 정지 및 운동 저장 공통 로직
  Future<void> _stopAutoAndSave() async {
    _timer?.cancel();
    await testChannel.stopWorkout();
    if (mounted) {
      setState(() {
        _count = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 남은 시간 계산 (표시용)
    int remainingSeconds = (_maxTicks - _count) * 5;
    String remainingTime = "${(remainingSeconds ~/ 60)}분 ${(remainingSeconds % 60)}초";

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Test (10Min/Random)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('남은 시간: $remainingTime',
                style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            Text('전송 횟수: $_count / $_maxTicks', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async => await testChannel.requestAuthorization(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text('1. 권한 요청'),
            ),

            ElevatedButton(
              onPressed: () async {
                await testChannel.startWorkout();
                _startAutoAdd();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(200, 50)),
              child: const Text('2. 운동 시작 (10분 자동)'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _stopAutoAndSave,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(200, 50)),
              child: const Text('3. 강제 종료 및 저장'),
            ),
          ],
        ),
      ),
    );
  }
}