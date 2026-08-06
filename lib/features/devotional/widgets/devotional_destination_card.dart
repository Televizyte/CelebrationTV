import 'package:flutter/material.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';

class DevotionalDestinationCard extends StatelessWidget {
  final DevotionalDestination destination;
  final VoidCallback onTap;

  const DevotionalDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final artwork = destination.artwork.trim();
    return Semantics(
      button: true,
      label: destination.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: CelebrationConfig.secondaryGold.withValues(alpha: 0.32),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF123E82), Color(0xFF07162F)],
            ),
            image: artwork.isEmpty
                ? null
                : DecorationImage(
                    image: NetworkImage(artwork),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Color(0x88000000),
                      BlendMode.darken,
                    ),
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: CelebrationConfig.secondaryGold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      devotionalIcon(destination),
                      color: CelebrationConfig.primaryRoyalBlue,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  destination.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (destination.subtitle.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 7),
                  Text(
                    destination.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData devotionalIcon(DevotionalDestination destination) {
  switch (destination.icon.trim().toLowerCase()) {
    case 'book':
    case 'menu_book':
    case 'auto_stories':
      return Icons.auto_stories_rounded;
    case 'play':
    case 'video':
    case 'live_tv':
      return Icons.play_circle_fill_rounded;
    case 'quote':
    case 'format_quote':
      return Icons.format_quote_rounded;
    case 'quiz':
    case 'question_answer':
      return Icons.quiz_rounded;
  }
  switch (destination.engineType) {
    case DevotionalEngineType.read:
      return Icons.auto_stories_rounded;
    case DevotionalEngineType.watch:
      return Icons.play_circle_fill_rounded;
    case DevotionalEngineType.quotes:
      return Icons.format_quote_rounded;
    case DevotionalEngineType.quiz:
      return Icons.quiz_rounded;
  }
}
