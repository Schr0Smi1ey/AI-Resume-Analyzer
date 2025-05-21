import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class KeywordChips extends StatelessWidget {
  final List<String> keywords;
  final Color color;

  const KeywordChips({super.key, required this.keywords, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          keywords.isEmpty
              ? [
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'No keywords available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ]
              : keywords.asMap().entries.map((entry) {
                final keyword = entry.value;
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * entry.key),
                  duration: const Duration(milliseconds: 500),
                  child: Chip(
                    label: Text(
                      keyword,
                      style: TextStyle(
                        color:
                            color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              }).toList(),
    );
  }
}
