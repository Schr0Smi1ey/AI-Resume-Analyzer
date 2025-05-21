import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/analysis_model.dart';

class ApiService extends ChangeNotifier {
  static const String _apiUrl = "https://openrouter.ai/api/v1/chat/completions";
  bool _isLoading = false;
  String? _lastError;
  AnalysisModel? _lastAnalysis;
  String? _lastRawResponse;
  String? _lastCleanedResponse;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  AnalysisModel? get lastAnalysis => _lastAnalysis;
  String? get lastRawResponse => _lastRawResponse;
  String? get lastCleanedResponse => _lastCleanedResponse;

  Future<AnalysisModel> analyzeResume({
    required String extractedText,
    required String jobDescription,
    String filePath = '',
  }) async {
    _isLoading = true;
    _lastError = null;
    _lastRawResponse = null;
    _lastCleanedResponse = null;
    notifyListeners();

    try {
      final String? apiKey = dotenv.env['OPENROUTER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Key not configured in .env file");
      }

      final prompt = _buildStrictAnalysisPrompt(
        resumeText: extractedText,
        jobDescription: jobDescription,
      );

      final response = await _sendAnalysisRequest(apiKey, prompt);
      _lastRawResponse = response.body;

      try {
        final analysis = _parseAndCleanResponse(response);
        _lastAnalysis = analysis;
        return analysis;
      } catch (e) {
        _lastCleanedResponse = _attemptToClean(response.body);
        throw _createDetailedException(e, response.body);
      }
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Exception _createDetailedException(dynamic error, String rawResponse) {
    final buffer = StringBuffer("Analysis failed:\n${error.toString()}");

    if (_lastCleanedResponse != null) {
      buffer.write("\n\nCleaned Response (scrollable in UI):");
    } else {
      buffer.write(
        "\n\nRaw Response (truncated): ${_truncateResponse(rawResponse)}",
      );
    }

    return Exception(buffer.toString());
  }

  String _buildStrictAnalysisPrompt({
    required String resumeText,
    required String jobDescription,
  }) {
    return """
    You are an expert resume analyst with deep knowledge of Applicant Tracking Systems (ATS), job market trends, and resume optimization. Analyze the provided resume against the job description and return a detailed JSON response. The analysis must include:

    1. ATS compatibility metrics (keyword optimization, formatting, scannability).
    2. Grammar and readability analysis (spelling, grammar, clarity, Flesch-Kincaid score).
    3. Job requirements coverage (skills, experience, qualifications alignment).
    4. Section-by-section evaluation (e.g., Education, Experience, Skills).
    5. Specific, actionable improvement suggestions with examples.
    6. Resume type detection (e.g., Chronological, Functional, Combination) based on structure and content.
    7. Keyword density and relevance analysis.
    8. Section coherence (logical flow, consistency, relevance to job).
    9. ATS-specific optimization tips (e.g., avoiding headers/footers, using standard fonts).
    10. Confidence score for the analysis accuracy.

    Expected JSON structure:
    {
      "summary": "string (brief overview of resume quality and job fit)",
      "success": boolean (true if analysis completed successfully),
      "atsScore": 0-100 (ATS compatibility score),
      "grammarScore": 0-100 (grammar and spelling quality),
      "readabilityScore": 0-100 (clarity and ease of reading),
      "verbQualityScore": 0-100 (strength of action verbs),
      "formatScore": 0-100 (visual and structural quality),
      "jobMatchScore": 0-100 (alignment with job requirements),
      "coherenceScore": 0-100 (logical flow and consistency),
      "keywordDensityScore": 0-100 (keyword usage effectiveness),
      "resumeType": "string (e.g., Chronological, Functional, Combination)",
      "confidenceScore": 0-100 (analysis accuracy confidence),
      "sections": [
        {
          "name": "string (e.g., Education, Experience)",
          "content": "string (extracted content of the section)",
          "score": 0-100 (section quality score),
          "feedback": "string (specific feedback)",
          "suggestions": ["string (actionable suggestions)"],
          "improvementExamples": ["string (specific examples for improvement)"]
        }
      ],
      "missingKeywords": ["string (keywords from job description not in resume)"],
      "matchedKeywords": ["string (keywords present in both resume and job description)"],
      "grammarIssues": ["string (specific grammar/spelling issues)"],
      "actionVerbSuggestions": ["string (suggested verbs to strengthen resume)"],
      "chronologyWarnings": ["string (issues with timeline, e.g., gaps, overlaps)"],
      "atsOptimizationTips": ["string (specific tips for ATS compatibility)"],
      "rawResponse": "string (optional raw AI response)"
    }

    Ensure all scores are integers between 0 and 100. Provide detailed, actionable feedback and examples. Return only valid JSON without additional text or formatting. If a score cannot be calculated, return 0 for that field.

    Job Description:
    ${jobDescription.trim()}

    Resume Content:
    ${resumeText.trim()}
    """;
  }

  Future<http.Response> _sendAnalysisRequest(
    String apiKey,
    String prompt,
  ) async {
    return await http
        .post(
          Uri.parse(_apiUrl),
          headers: _buildHeaders(apiKey),
          body: jsonEncode(_buildRequestBody(prompt)),
        )
        .timeout(const Duration(seconds: 180));
  }

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
      "HTTP-Referer": "https://yourdomain.com",
      "X-Title": "AI Resume Analyzer",
    };
  }

  Map<String, dynamic> _buildRequestBody(String prompt) {
    return {
      "model": "deepseek/deepseek-chat:free",
      "messages": [
        {
          "role": "system",
          "content":
              "You must return only valid JSON without any additional text or formatting.",
        },
        {"role": "user", "content": prompt},
      ],
      "response_format": {"type": "json_object"},
      "temperature": 0.1,
    };
  }

  AnalysisModel _parseAndCleanResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        "API Error ${response.statusCode}: ${_truncateResponse(response.body)}",
      );
    }

    final cleanedBody = _cleanJsonResponse(response.body);
    _lastCleanedResponse = cleanedBody;

    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanedBody);
      debugPrint(
        "Parsed JSON response: ${jsonEncode(jsonResponse)}",
      ); // Debug log
      final content = _extractContentFromResponse(jsonResponse);
      return _parseValidatedAnalysis(content);
    } catch (e) {
      throw Exception(
        "Failed to parse response: ${e.toString()}\nCleaned response: $cleanedBody",
      );
    }
  }

  String _extractContentFromResponse(Map<String, dynamic> jsonResponse) {
    try {
      if (jsonResponse.containsKey('choices') &&
          jsonResponse['choices'] is List &&
          jsonResponse['choices'].isNotEmpty &&
          jsonResponse['choices'][0]['message'] != null &&
          jsonResponse['choices'][0]['message']['content'] != null) {
        return jsonResponse['choices'][0]['message']['content'] as String;
      }

      debugPrint("Invalid structure in OpenRouter response: $jsonResponse");
      throw Exception(
        "Invalid response structure: 'choices[0].message.content' not found or null.\nRaw JSON: ${jsonEncode(jsonResponse)}",
      );
    } catch (e) {
      throw Exception("Invalid response structure: ${e.toString()}");
    }
  }

  String _cleanJsonResponse(String rawResponse) {
    String cleaned = rawResponse.replaceAll(RegExp(r'```(json)?'), '').trim();
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (jsonMatch == null) {
      throw FormatException("No valid JSON found in response");
    }
    return jsonMatch.group(0)!;
  }

  AnalysisModel _parseValidatedAnalysis(String content) {
    try {
      final analysisJson = jsonDecode(content) as Map<String, dynamic>;
      return AnalysisModel.fromJson(analysisJson);
    } catch (e) {
      throw Exception("Failed to parse analysis: ${e.toString()}");
    }
  }

  String _attemptToClean(String rawResponse) {
    try {
      return _cleanJsonResponse(rawResponse);
    } catch (e) {
      final jsonStart = rawResponse.indexOf('{');
      return jsonStart >= 0 ? rawResponse.substring(jsonStart) : rawResponse;
    }
  }

  String _truncateResponse(String response, [int length = 500]) {
    return response.length > length
        ? '${response.substring(0, length)}...'
        : response;
  }

  void clearAnalysis() {
    _lastAnalysis = null;
    _lastError = null;
    _lastRawResponse = null;
    _lastCleanedResponse = null;
    notifyListeners();
  }
}
