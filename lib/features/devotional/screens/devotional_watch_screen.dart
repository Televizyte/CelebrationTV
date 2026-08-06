import 'package:flutter/material.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';

class DevotionalWatchScreen extends StatelessWidget {
  final DevotionalDestination destination;
  final VoidCallback onBack;

  const DevotionalWatchScreen({
    super.key,
    required this.destination,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final playback = destination.playback;
    return Scaffold(
      backgroundColor: const Color(0xFF050C19),
      appBar: AppBar(
        backgroundColor: CelebrationConfig.primaryRoyalBlue,
        leading: BackButton(onPressed: onBack),
        title: Text(destination.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF10213D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: CelebrationConfig.secondaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 58,
                    color: CelebrationConfig.secondaryGold,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    playback.hasSource
                        ? 'A provider-neutral video source is ready for the shared playback engine.'
                        : 'No devotional video is available yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, height: 1.45),
                  ),
                  if (playback.hasSource) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      <String>[
                        if (playback.sourceType.isNotEmpty) playback.sourceType,
                        if (playback.provider.isNotEmpty) playback.provider,
                        if (playback.live) 'live',
                      ].join(' • '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Playback, Bible, Notes and related content remain protected until the shared player engine is connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
