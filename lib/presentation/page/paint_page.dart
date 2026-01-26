import 'package:flutter/material.dart';
import 'package:run_run/presentation/widgets/line_painter.dart';

class PaintPage extends StatefulWidget {
  @override
  _PaintPageState createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  final List<Offset> points = [
    Offset(0, 0),
    Offset(50, 50),
    Offset(100, 100),
    Offset(150, 150),
    Offset(200, 200),
    Offset(250, 150),
    Offset(300, 100),
    Offset(350, 50),
    Offset(400, 0),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // TickerProviderStateMixin 사용
      duration: const Duration(seconds: 5), // 🚨 5초 동안 애니메이션 진행
    )..forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chart Page"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 400,
              width: 400,
              color: Colors.green,
              // 🚨 AnimatedBuilder로 CustomPaint를 감쌉니다.
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LinePainter(points, _controller.value),
                    child: child, // 내부 Container를 child로 전달
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}