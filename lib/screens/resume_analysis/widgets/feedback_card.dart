import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FeedbackCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool collapsible;
  final bool initiallyExpanded;

  const FeedbackCard({
    super.key,
    required this.title,
    required this.child,
    this.collapsible = false,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInUp(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.1),
                theme.colorScheme.primaryContainer.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              collapsible
                  ? ExpansionTile(
                    title: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    initiallyExpanded: initiallyExpanded,
                    children: [
                      Padding(padding: const EdgeInsets.all(16), child: child),
                    ],
                  )
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        child,
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
