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
            duration: const Duration(milliseconds: 600),
            child: SpinKitFadingCircle(
              color: const Color(0xFF4CAF50),
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Analyzing your resume...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
