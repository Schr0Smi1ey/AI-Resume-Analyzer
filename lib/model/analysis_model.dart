import 'package:intl/intl.dart';

class AnalysisModel {
  final String summary;
  final bool success;
  final int atsScore;
  final int grammarScore;
  final int readabilityScore;
  final int verbQualityScore;
  final int formatScore;
  final int jobMatchScore;
  final int? coherenceScore;
  final int? keywordDensityScore;
  final String resumeType;
  final int? confidenceScore;
  final List<ResumeSection> sections;
  final List<String>? missingKeywords;
  final List<String>? matchedKeywords;
  final List<String>? grammarIssues;
  final List<String>? actionVerbSuggestions;
  final List<String>? chronologyWarnings;
  final List<String>? atsOptimizationTips;
  final String? rawResponse;
  final DateTime timestamp;

  AnalysisModel({
    required this.summary,
    required this.success,
    required this.atsScore,
    required this.grammarScore,
    required this.readabilityScore,
    required this.verbQualityScore,
    required this.formatScore,
    required this.jobMatchScore,
    this.coherenceScore,
    this.keywordDensityScore,
    required this.resumeType,
    this.confidenceScore,
    required this.sections,
    this.missingKeywords,
    this.matchedKeywords,
    this.grammarIssues,
    this.actionVerbSuggestions,
    this.chronologyWarnings,
    this.atsOptimizationTips,
    this.rawResponse,
    required this.timestamp,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      summary: json['summary'] as String? ?? 'No summary provided',
      success: json['success'] as bool? ?? false,
      atsScore: (json['atsScore'] as num?)?.toInt() ?? 0,
      grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
      readabilityScore: (json['readabilityScore'] as num?)?.toInt() ?? 0,
      verbQualityScore: (json['verbQualityScore'] as num?)?.toInt() ?? 0,
      formatScore: (json['formatScore'] as num?)?.toInt() ?? 0,
      jobMatchScore: (json['jobMatchScore'] as num?)?.toInt() ?? 0,
      coherenceScore: (json['coherenceScore'] as num?)?.toInt(),
      keywordDensityScore: (json['keywordDensityScore'] as num?)?.toInt(),
      resumeType: json['resumeType'] as String? ?? 'Unknown',
      confidenceScore: (json['confidenceScore'] as num?)?.toInt(),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => ResumeSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      missingKeywords:
          (json['missingKeywords'] as List<dynamic>?)?.cast<String>(),
      matchedKeywords:
          (json['matchedKeywords'] as List<dynamic>?)?.cast<String>(),
      grammarIssues: (json['grammarIssues'] as List<dynamic>?)?.cast<String>(),
      actionVerbSuggestions:
          (json['actionVerbSuggestions'] as List<dynamic>?)?.cast<String>(),
      chronologyWarnings:
          (json['chronologyWarnings'] as List<dynamic>?)?.cast<String>(),
      atsOptimizationTips:
          (json['atsOptimizationTips'] as List<dynamic>?)?.cast<String>(),
      rawResponse: json['rawResponse'] as String?,
      timestamp: DateTime.now(),
    );
  }

  String get formattedTimestamp =>
      DateFormat('MMM d, yyyy h:mm a').format(timestamp);
}

class ResumeSection {
  final String name;
  final String content;
  final int score;
  final String feedback;
  final List<String> suggestions;
  final List<String> improvementExamples;

  ResumeSection({
    required this.name,
    required this.content,
    required this.score,
    required this.feedback,
    required this.suggestions,
    required this.improvementExamples,
  });

  factory ResumeSection.fromJson(Map<String, dynamic> json) {
    return ResumeSection(
      name: json['name'] as String? ?? 'Unnamed Section',
      content: json['content'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? 'No feedback provided',
      suggestions:
          (json['suggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      improvementExamples:
          (json['improvementExamples'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
