import 'package:flutter/material.dart';

class HomeRecentRunTile extends StatelessWidget {
  const HomeRecentRunTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateText,
  });

  final String title;
  final String subtitle;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: const Icon(Icons.directions_run_outlined),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(dateText, style: TextStyle(color: Colors.grey[700])),
      onTap: () {},
    );
  }
}
