import 'package:flutter/material.dart';

class HomeBigStat extends StatelessWidget {
  const HomeBigStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
