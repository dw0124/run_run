import 'package:flutter/material.dart';

class HomeCardTitle extends StatelessWidget {
  const HomeCardTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
