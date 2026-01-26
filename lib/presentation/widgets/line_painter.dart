import 'dart:math' as math;

import 'package:flutter/material.dart';

// class LinePainter extends CustomPainter {
//
//   final List<double> lngArr = [10, 10, 20, 30, 40, 50, 0];
//   final List<double> latArr = [40, 10, 30, 5, 50, 30, 0];
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.lightBlueAccent
//       ..strokeWidth = 3.0
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final scale = 5;
//
//     Path path = Path();
//     path.moveTo(0.0, 0.0); // (0.0, 0.0) 좌표로 이동
//
//     for(int i = 0; i < 7; i++) {
//       final lat = latArr[i] * scale;
//       final lng = lngArr[i] * scale;
//
//       path.lineTo(lng, lat);
//     }
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final double progress;

  LinePainter(this.points, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round       // 선 끝을 둥글게
      ..strokeJoin = StrokeJoin.round;    // 꺾이는 부분(모서리)을 둥글게

    // 전체 길이 계산
    final lengths = <double>[];
    double totalLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final len = (points[i + 1] - points[i]).distance;
      lengths.add(len);
      totalLength += len;
    }

    final targetLength = totalLength * progress;
    double drawnLength = 0;

    // 선분을 순서대로 그리기
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final segmentLength = lengths[i];

      if (drawnLength + segmentLength < targetLength) {
        // 전체 선분을 그림
        canvas.drawLine(start, end, paint);
        drawnLength += segmentLength;
      } else {
        // 부분만 그림
        final remain = targetLength - drawnLength;
        if (remain > 0) {
          final t = remain / segmentLength;
          final partialEnd = Offset(
            start.dx + (end.dx - start.dx) * t,
            start.dy + (end.dy - start.dy) * t,
          );
          canvas.drawLine(start, partialEnd, paint);
        }
        break;
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}