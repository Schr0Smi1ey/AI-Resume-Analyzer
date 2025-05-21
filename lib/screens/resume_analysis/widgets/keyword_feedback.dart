import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

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
        if (matchedKeywords.isNotEmpty) ...[
          Text(
            'Matched Keywords:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FadeIn(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  matchedKeywords
                      .map((keyword) => _buildChip(keyword, Colors.green))
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (missingKeywords.isNotEmpty) ...[
          Text(
            'Missing Keywords:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FadeIn(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  missingKeywords
                      .map((keyword) => _buildChip(keyword, Colors.orange))
                      .toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String keyword, Color color) {
    return Chip(
      label: Text(
        keyword,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
