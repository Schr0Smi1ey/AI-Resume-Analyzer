import 'package:intl/intl.dart';

class AnalysisModel {
  final String summary;
  final bool success;
  final Metadata metadata;
  final int atsScore;
  final int grammarScore;
  final int readabilityScore;
  final int verbQualityScore;
  final int formatScore;
  final int jobMatchScore;
  final int coherenceScore;
  final int keywordDensityScore;
  final List<String> generalSuggestions;
  final List<String> atsOptimizationTips;
  final List<String> actionVerbSuggestions;
  final List<String> chronologyWarnings;
  final List<String> missingKeywords;
  final List<String> matchedKeywords;
  final List<String> grammarIssues;
  final List<String> atsOptimizationExamples;
  final List<ResumeSection> sections;
  final int confidenceScore;
  final String rawResponse;
  final DateTime timestamp;
  String get formattedTimestamp =>
      DateFormat('MMM dd, yyyy HH:mm').format(timestamp);

  AnalysisModel({
    required this.summary,
    required this.success,
    required this.metadata,
    required this.atsScore,
    required this.grammarScore,
    required this.readabilityScore,
    required this.verbQualityScore,
    required this.formatScore,
    required this.jobMatchScore,
    required this.coherenceScore,
    required this.keywordDensityScore,
    required this.generalSuggestions,
    required this.atsOptimizationTips,
    required this.actionVerbSuggestions,
    required this.chronologyWarnings,
    required this.missingKeywords,
    required this.matchedKeywords,
    required this.grammarIssues,
    required this.atsOptimizationExamples,
    required this.sections,
    required this.confidenceScore,
    required this.rawResponse,
    required this.timestamp,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    try {
      final metadata = Metadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      );
      return AnalysisModel(
        summary: json['summary'] as String? ?? 'No summary provided.',
        success: json['success'] as bool? ?? false,
        metadata: metadata,
        atsScore: (json['atsScore'] as num?)?.toInt() ?? 0,
        grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
        readabilityScore: (json['readabilityScore'] as num?)?.toInt() ?? 0,
        verbQualityScore: (json['verbQualityScore'] as num?)?.toInt() ?? 0,
        formatScore: (json['formatScore'] as num?)?.toInt() ?? 0,
        jobMatchScore: (json['jobMatchScore'] as num?)?.toInt() ?? 0,
        coherenceScore: (json['coherenceScore'] as num?)?.toInt() ?? 0,
        keywordDensityScore:
            (json['keywordDensityScore'] as num?)?.toInt() ?? 0,
        generalSuggestions:
            (json['generalSuggestions'] as List<dynamic>?)?.cast<String>() ??
            ['No suggestions provided.'],
        atsOptimizationTips:
            (json['atsOptimizationTips'] as List<dynamic>?)?.cast<String>() ??
            ['No ATS tips provided.'],
        actionVerbSuggestions:
            (json['actionVerbSuggestions'] as List<dynamic>?)?.cast<String>() ??
            ['No verb suggestions provided.'],
        chronologyWarnings:
            (json['chronologyWarnings'] as List<dynamic>?)?.cast<String>() ??
            ['No chronology issues detected.'],
        missingKeywords:
            (json['missingKeywords'] as List<dynamic>?)?.cast<String>() ??
            ['No missing keywords detected.'],
        matchedKeywords:
            (json['matchedKeywords'] as List<dynamic>?)?.cast<String>() ??
            ['No matched keywords detected.'],
        grammarIssues:
            (json['grammarIssues'] as List<dynamic>?)?.cast<String>() ??
            ['No grammar issues detected.'],
        atsOptimizationExamples:
            (json['atsOptimizationExamples'] as List<dynamic>?)
                ?.cast<String>() ??
            ['No ATS examples provided.'],
        sections:
            (json['sections'] as List<dynamic>?)
                ?.map((e) => ResumeSection.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 0,
        rawResponse: json['rawResponse'] as String? ?? 'No raw response.',
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse AnalysisModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'success': success,
      'metadata': metadata.toJson(),
      'atsScore': atsScore,
      'grammarScore': grammarScore,
      'readabilityScore': readabilityScore,
      'verbQualityScore': verbQualityScore,
      'formatScore': formatScore,
      'jobMatchScore': jobMatchScore,
      'coherenceScore': coherenceScore,
      'keywordDensityScore': keywordDensityScore,
      'generalSuggestions': generalSuggestions,
      'atsOptimizationTips': atsOptimizationTips,
      'actionVerbSuggestions': actionVerbSuggestions,
      'chronologyWarnings': chronologyWarnings,
      'missingKeywords': missingKeywords,
      'matchedKeywords': matchedKeywords,
      'grammarIssues': grammarIssues,
      'atsOptimizationExamples': atsOptimizationExamples,
      'sections': sections.map((e) => e.toJson()).toList(),
      'confidenceScore': confidenceScore,
      'rawResponse': rawResponse,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Metadata {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String resumeType;
  final String experienceLevel;
  final String industry;

  Metadata({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.resumeType,
    required this.experienceLevel,
    required this.industry,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? 'Unknown',
      phone: json['phone'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? 'Unknown',
      resumeType: json['resumeType'] as String? ?? 'Unknown',
      experienceLevel: json['experienceLevel'] as String? ?? 'Unknown',
      industry: json['industry'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'resumeType': resumeType,
      'experienceLevel': experienceLevel,
      'industry': industry,
    };
  }
}

class Scoring {
  final int atsScore;
  final int grammarScore;
  final int readabilityScore;
  final int verbQualityScore;
  final int formatScore;
  final int jobMatchScore;
  final int coherenceScore;
  final int keywordDensityScore;

  Scoring({
    required this.atsScore,
    required this.grammarScore,
    required this.readabilityScore,
    required this.verbQualityScore,
    required this.formatScore,
    required this.jobMatchScore,
    required this.coherenceScore,
    required this.keywordDensityScore,
  });

  factory Scoring.fromJson(Map<String, dynamic> json) {
    return Scoring(
      atsScore: (json['atsScore'] as num?)?.toInt() ?? 0,
      grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
      readabilityScore: (json['readabilityScore'] as num?)?.toInt() ?? 0,
      verbQualityScore: (json['verbQualityScore'] as num?)?.toInt() ?? 0,
      formatScore: (json['formatScore'] as num?)?.toInt() ?? 0,
      jobMatchScore: (json['jobMatchScore'] as num?)?.toInt() ?? 0,
      coherenceScore: (json['coherenceScore'] as num?)?.toInt() ?? 0,
      keywordDensityScore: (json['keywordDensityScore'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'atsScore': atsScore,
      'grammarScore': grammarScore,
      'readabilityScore': readabilityScore,
      'verbQualityScore': verbQualityScore,
      'formatScore': formatScore,
      'jobMatchScore': jobMatchScore,
      'coherenceScore': coherenceScore,
      'keywordDensityScore': keywordDensityScore,
    };
  }
}

class Feedback {
  final List<String> generalSuggestions;
  final List<String> atsOptimizationTips;
  final List<String> actionVerbSuggestions;
  final List<String> chronologyWarnings;
  final List<String> missingKeywords;
  final List<String> matchedKeywords;
  final List<String> grammarIssues;
  final List<String> atsOptimizationExamples;

  Feedback({
    required this.generalSuggestions,
    required this.atsOptimizationTips,
    required this.actionVerbSuggestions,
    required this.chronologyWarnings,
    required this.missingKeywords,
    required this.matchedKeywords,
    required this.grammarIssues,
    required this.atsOptimizationExamples,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      generalSuggestions:
          (json['generalSuggestions'] as List<dynamic>?)?.cast<String>() ??
          ['No suggestions provided.'],
      atsOptimizationTips:
          (json['atsOptimizationTips'] as List<dynamic>?)?.cast<String>() ??
          ['No ATS tips provided.'],
      actionVerbSuggestions:
          (json['actionVerbSuggestions'] as List<dynamic>?)?.cast<String>() ??
          ['No verb suggestions provided.'],
      chronologyWarnings:
          (json['chronologyWarnings'] as List<dynamic>?)?.cast<String>() ??
          ['No chronology issues detected.'],
      missingKeywords:
          (json['missingKeywords'] as List<dynamic>?)?.cast<String>() ??
          ['No missing keywords detected.'],
      matchedKeywords:
          (json['matchedKeywords'] as List<dynamic>?)?.cast<String>() ??
          ['No matched keywords detected.'],
      grammarIssues:
          (json['grammarIssues'] as List<dynamic>?)?.cast<String>() ??
          ['No grammar issues detected.'],
      atsOptimizationExamples:
          (json['atsOptimizationExamples'] as List<dynamic>?)?.cast<String>() ??
          ['No ATS examples provided.'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalSuggestions': generalSuggestions,
      'atsOptimizationTips': atsOptimizationTips,
      'actionVerbSuggestions': actionVerbSuggestions,
      'chronologyWarnings': chronologyWarnings,
      'missingKeywords': missingKeywords,
      'matchedKeywords': matchedKeywords,
      'grammarIssues': grammarIssues,
      'atsOptimizationExamples': atsOptimizationExamples,
    };
  }
}

class ResumeSection {
  final String name;
  final List<String> content;
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
      name: json['name'] as String? ?? 'Unknown',
      content: (json['content'] as List<dynamic>?)?.cast<String>() ?? [],
      score: (json['score'] as num?)?.toInt() ?? 0,
      feedback: json['feedback'] as String? ?? 'No feedback provided.',
      suggestions:
          (json['suggestions'] as List<dynamic>?)?.cast<String>() ??
          ['No suggestions provided.'],
      improvementExamples:
          (json['improvementExamples'] as List<dynamic>?)?.cast<String>() ??
          ['No examples provided.'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
      'score': score,
      'feedback': feedback,
      'suggestions': suggestions,
      'improvementExamples': improvementExamples,
    };
  }
}
