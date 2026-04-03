import 'package:flutter/material.dart';

class HomeGoalLine extends StatelessWidget {
  const HomeGoalLine({
    super.key,
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.progress,
    required this.footer,
    required this.brand,
  });

  final String label;
  final String leftValue;
  final String rightValue;
  final double progress;
  final String footer;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(leftValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(' / $rightValue', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: brand,
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 10),
        Text(footer, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
