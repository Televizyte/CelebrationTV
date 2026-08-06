import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';

class DevotionalReadScreen extends StatelessWidget {
  final DevotionalDestination destination;
  final VoidCallback onBack;
  final ValueChanged<String> onNavigate;

  const DevotionalReadScreen({
    super.key,
    required this.destination,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final post = destination.post;
    return Scaffold(
      backgroundColor: const Color(0xFF050C19),
      appBar: AppBar(
        backgroundColor: CelebrationConfig.primaryRoyalBlue,
        leading: BackButton(onPressed: onBack),
        title: Text(destination.title),
      ),
      body: post.hasContent
          ? ListView(
              padding: const EdgeInsets.all(18),
              children: <Widget>[
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (post.publicationDate.isNotEmpty)
                  _MutedText(post.publicationDate),
                if (post.scripture.isNotEmpty)
                  _ContentBlock(title: 'Scripture', body: post.scripture),
                if (post.body.isNotEmpty)
                  _ContentBlock(title: 'Devotional', body: post.body),
                if (post.keyPoint.isNotEmpty)
                  _ContentBlock(title: 'Remember This', body: post.keyPoint),
                if (post.assignments.isNotEmpty)
                  _ContentBlock(
                    title: 'Assignments',
                    body: post.assignments.map((item) => '• $item').join('\n'),
                  ),
                if (post.prayer.isNotEmpty)
                  _ContentBlock(title: 'Prayer', body: post.prayer),
                if (post.furtherReading.isNotEmpty)
                  _ContentBlock(
                    title: 'Further Reading',
                    body: post.furtherReading,
                  ),
                if (post.author.isNotEmpty) _MutedText(post.author),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: '${post.title}\n\n${post.body}'),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Devotional copied for sharing.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate('/tools/notes'),
                      icon: const Icon(Icons.note_alt_outlined),
                      label: const Text('Notes'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate('/tools/quote-creator'),
                      icon: const Icon(Icons.format_quote_rounded),
                      label: const Text('Quote Creator'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Saving will be enabled with the content engine.',
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.bookmark_border_rounded),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          : const _ReadEmptyState(),
    );
  }
}

class _ContentBlock extends StatelessWidget {
  final String title;
  final String body;

  const _ContentBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF10213D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: CelebrationConfig.secondaryGold.withValues(alpha: 0.24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: CelebrationConfig.secondaryGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(body, style: const TextStyle(height: 1.55)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  final String text;

  const _MutedText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
        ),
      );
}

class _ReadEmptyState extends StatelessWidget {
  const _ReadEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'No devotional reading is available yet. Please check again after new content is published.',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
