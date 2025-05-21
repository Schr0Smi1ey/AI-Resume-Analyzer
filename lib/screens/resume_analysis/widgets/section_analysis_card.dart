import 'package:flutter/material.dart';
import '../../../model/analysis_model.dart';

class SectionAnalysisCard extends StatelessWidget {
  final ResumeSection section;
  final bool compact;
  final VoidCallback? onImprovePressed;

  const SectionAnalysisCard({
    required this.section,
    this.compact = false,
    this.onImprovePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = section.score.clamp(0, 100);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScoreChip(score: score),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (section.content.isNotEmpty) ...[
              _ContentPreview(content: section.content),
              const SizedBox(height: 12),
            ],
            Text(section.feedback, style: theme.textTheme.bodyMedium),
            if (section.suggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Suggestions:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...section.suggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!compact && onImprovePressed != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onImprovePressed,
                  child: const Text('Improve This Section'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int score;

  const _ScoreChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score < 40) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }
}

class _ContentPreview extends StatelessWidget {
  final String content;

  const _ContentPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
