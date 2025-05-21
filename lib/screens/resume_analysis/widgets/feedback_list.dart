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
          items.asMap().entries.map((entry) {
            final item = entry.value;
            return FadeInUp(
              delay: Duration(milliseconds: 100 * entry.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: color,
                      semanticLabel: 'Feedback item',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
