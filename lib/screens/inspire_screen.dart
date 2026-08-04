import 'package:flutter/material.dart';

class InspireScreen extends StatelessWidget {
  const InspireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quotes = [
      "Be still and know that I am God.",
      "The Word is working in me.",
      "I am favored and loved by God.",
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: quotes.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.bolt),
        title: Text(quotes[i]),
      ),
    );
  }
}
