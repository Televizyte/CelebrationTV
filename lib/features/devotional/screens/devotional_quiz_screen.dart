import 'package:flutter/material.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';

class DevotionalQuizScreen extends StatelessWidget {
  final DevotionalDestination destination;
  final bool capabilityEnabled;
  final VoidCallback onBack;

  const DevotionalQuizScreen({
    super.key,
    required this.destination,
    required this.capabilityEnabled,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final definition = destination.settings['quiz_definition'] ??
        destination.metadata['quiz_definition'];
    final hasDefinition = definition is Map && definition.isNotEmpty;
    final available = capabilityEnabled && hasDefinition;
    return Scaffold(
      backgroundColor: const Color(0xFF050C19),
      appBar: AppBar(
        backgroundColor: CelebrationConfig.primaryRoyalBlue,
        leading: BackButton(onPressed: onBack),
        title: Text(destination.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.quiz_rounded,
                size: 58,
                color: CelebrationConfig.secondaryGold,
              ),
              const SizedBox(height: 18),
              Text(
                available
                    ? 'The quiz definition is available. The shared quiz runtime will be connected in its focused phase.'
                    : 'This devotional quiz is not available yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.45),
              ),
              const SizedBox(height: 10),
              Text(
                'Visibility, questions and publication state are controlled by AppsHub.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
