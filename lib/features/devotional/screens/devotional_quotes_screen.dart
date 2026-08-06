import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';

class DevotionalQuotesScreen extends StatelessWidget {
  final DevotionalDestination destination;
  final VoidCallback onBack;
  final ValueChanged<String> onNavigate;

  const DevotionalQuotesScreen({
    super.key,
    required this.destination,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final quotes = destination.quotes;
    return Scaffold(
      backgroundColor: const Color(0xFF050C19),
      appBar: AppBar(
        backgroundColor: CelebrationConfig.primaryRoyalBlue,
        leading: BackButton(onPressed: onBack),
        title: Text(destination.title),
      ),
      body: quotes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No devotional quotes are available yet. Designed cards will appear after they are published.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: quotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final quote = quotes[index];
                return Column(
                  children: <Widget>[
                    DevotionalQuoteCard(quote: quote),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: <String>[
                                  quote.text,
                                  if (quote.attribution.isNotEmpty)
                                    quote.attribution,
                                ].join('\n— '),
                              ),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Quote copied for sharing.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share'),
                        ),
                        TextButton.icon(
                          onPressed: () => onNavigate('/tools/notes'),
                          icon: const Icon(Icons.note_alt_outlined),
                          label: const Text('Notes'),
                        ),
                        TextButton.icon(
                          onPressed: () => onNavigate('/tools/quote-creator'),
                          icon: const Icon(Icons.design_services_outlined),
                          label: const Text('Quote Creator'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class DevotionalQuoteCard extends StatelessWidget {
  final DevotionalQuote quote;

  const DevotionalQuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final design = quote.design;
    final primary = _color(
      design.backgroundColor,
      CelebrationConfig.primaryRoyalBlue,
    );
    final secondary = _color(
      design.gradientColor,
      const Color(0xFF07162F),
    );
    final textColor = _color(design.textColor, Colors.white);
    final backgroundImage = design.backgroundImage;
    return AspectRatio(
      aspectRatio: design.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[primary, secondary],
            ),
            image: backgroundImage.isEmpty
                ? null
                : DecorationImage(
                    image: NetworkImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
          ),
          child: ColoredBox(
            color: Colors.black.withValues(alpha: design.overlay),
            child: Padding(
              padding: EdgeInsets.all(design.padding),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: _alignment(design.alignment),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: _crossAxis(design.alignment),
                      children: <Widget>[
                        Text(
                          quote.text,
                          textAlign: _textAlign(design.alignment),
                          style: TextStyle(
                            color: textColor,
                            fontFamily: _fontFamily(design.fontFamily),
                            fontSize: design.fontSize,
                            fontWeight: _fontWeight(design.fontWeight),
                            height: design.lineHeight,
                          ),
                        ),
                        if (quote.attribution.isNotEmpty ||
                            design.attribution.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          Text(
                            quote.attribution.isNotEmpty
                                ? quote.attribution
                                : design.attribution,
                            textAlign: _textAlign(design.alignment),
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (design.watermark.isNotEmpty)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Text(
                        design.watermark,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.42),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
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

Color _color(String value, Color fallback) {
  final normalized = value.trim().replaceFirst('#', '');
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.tryParse(hex, radix: 16) ?? fallback.toARGB32());
}

FontWeight _fontWeight(int weight) {
  if (weight >= 900) return FontWeight.w900;
  if (weight >= 800) return FontWeight.w800;
  if (weight >= 700) return FontWeight.w700;
  if (weight >= 600) return FontWeight.w600;
  if (weight >= 500) return FontWeight.w500;
  return FontWeight.w400;
}

String? _fontFamily(String value) {
  switch (value.trim().toLowerCase()) {
    case 'serif':
    case 'georgia':
      return 'serif';
    case 'monospace':
      return 'monospace';
    default:
      return null;
  }
}

TextAlign _textAlign(String value) {
  switch (value.trim().toLowerCase()) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    default:
      return TextAlign.center;
  }
}

Alignment _alignment(String value) {
  switch (value.trim().toLowerCase()) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    default:
      return Alignment.center;
  }
}

CrossAxisAlignment _crossAxis(String value) {
  switch (value.trim().toLowerCase()) {
    case 'left':
      return CrossAxisAlignment.start;
    case 'right':
      return CrossAxisAlignment.end;
    default:
      return CrossAxisAlignment.center;
  }
}
