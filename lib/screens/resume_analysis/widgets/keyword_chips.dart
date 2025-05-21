import 'package:flutter/material.dart';

class KeywordChips extends StatelessWidget {
  final List<String> keywords;
  final Color color;

  const KeywordChips({super.key, required this.keywords, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          keywords
              .map(
                (keyword) => Chip(
                  label: Text(keyword, style: TextStyle(color: Colors.white)),
                  backgroundColor: color,
                ),
              )
              .toList(),
    );
  }
}
