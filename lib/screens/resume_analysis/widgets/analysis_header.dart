import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../model/analysis_model.dart';

class AnalysisHeader extends StatelessWidget {
  final AnalysisModel analysis;
  final bool compact;

  const AnalysisHeader({
    super.key,
    required this.analysis,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: compact ? const EdgeInsets.all(12) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withOpacity(0.2),
            colors.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FadeIn(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'analysis_status_${analysis.timestamp}',
              child: Icon(
                analysis.success ? Icons.check_circle : Icons.warning,
                color: analysis.success ? colors.primary : colors.error,
                size: compact ? 28 : 36,
                semanticLabel:
                    analysis.success
                        ? 'Analysis Successful'
                        : 'Analysis Warning',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.summary,
                    style:
                        compact
                            ? theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                            : theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            analysis.resumeType,
                            style: TextStyle(
                              color: colors.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: colors.primaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Chip(
                          label: Text(
                            analysis.formattedTimestamp,
                            style: TextStyle(
                              color: colors.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: colors.primaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
