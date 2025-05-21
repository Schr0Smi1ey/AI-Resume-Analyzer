import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../model/analysis_model.dart';

class SectionFeedbackCard extends StatelessWidget {
  final ResumeSection section;
  final VoidCallback onImprovePressed;

  const SectionFeedbackCard({
    super.key,
    required this.section,
    required this.onImprovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black26,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    section.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    '${section.score}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF388E3C),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.white,
              hoverColor: const Color(0xFF388E3C),
              onPressed: onImprovePressed,
              tooltip: 'Improve Section',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            section.content.isEmpty
                                ? [
                                  Text(
                                    'No content available.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ]
                                : section.content.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Color(0xFF388E3C),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurface,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                      ),
                    ),
                    if (section.suggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Suggestions:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.suggestions.map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (section.improvementExamples.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Improvement Examples:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.improvementExamples.map(
                        (example) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  example,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
