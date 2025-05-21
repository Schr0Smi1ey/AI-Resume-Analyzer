import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AnalysisLoading extends StatelessWidget {
  const AnalysisLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            child: SpinKitFadingCircle(
              color: theme.colorScheme.primary,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'Analyzing your resume...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
