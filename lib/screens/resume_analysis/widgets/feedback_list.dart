import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FeedbackList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;

  const FeedbackList({
    super.key,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.isEmpty
              ? [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No feedback available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ]
              : items.asMap().entries.map((entry) {
                final item = entry.value;
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * entry.key),
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color:
                              color == Colors.red || color == Colors.orange
                                  ? color
                                  : const Color(0xFF009688),
                          semanticLabel: 'Feedback item',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
    );
  }
}
