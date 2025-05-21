import 'package:flutter/material.dart';
import 'keyword_chips.dart';

class KeywordFeedback extends StatelessWidget {
  final List<String> matchedKeywords;
  final List<String> missingKeywords;

  const KeywordFeedback({
    super.key,
    required this.matchedKeywords,
    required this.missingKeywords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matched Keywords:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        KeywordChips(keywords: matchedKeywords, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 16),
        Text(
          'Missing Keywords:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        KeywordChips(keywords: missingKeywords, color: Colors.red),
      ],
    );
  }
}
