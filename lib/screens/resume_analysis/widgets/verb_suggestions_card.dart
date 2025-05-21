import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'feedback_list.dart';

class VerbSuggestionsCard extends StatelessWidget {
  final List<String> suggestions;

  const VerbSuggestionsCard({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black26,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF009688)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Verb Suggestions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                FeedbackList(
                  items: suggestions,
                  icon: Icons.arrow_forward,
                  color: const Color(0xFF009688),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
