import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/analysis_model.dart' as model;

class ApiService extends ChangeNotifier {
  static const String _apiUrl = "https://openrouter.ai/api/v1/chat/completions";
  bool _isLoading = false;
  String? _lastError;
  model.AnalysisModel? _lastAnalysis;
  String? _lastRawResponse;
  String? _lastCleanedResponse;

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  model.AnalysisModel? get lastAnalysis => _lastAnalysis;
  String? get lastRawResponse => _lastRawResponse;
  String? get lastCleanedResponse => _lastCleanedResponse;

  Future<model.AnalysisModel> analyzeResume({
    required String extractedText,
    String jobDescription = '',
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
        throw Exception('API Key missing in .env file (OPENROUTER_API_KEY).');
      }

      debugPrint('Sending API request...');
      final prompt = _buildStrictAnalysisPrompt(
        resumeText: extractedText,
        jobDescription: jobDescription,
      );

      final response = await _sendAnalysisRequest(apiKey, prompt);
      _lastRawResponse = response.body;

      debugPrint('API response received: ${response.statusCode}');
      final analysis = _parseAndCleanResponse(response);
      _lastAnalysis = analysis;
      debugPrint('Analysis parsed successfully.');
      return analysis;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Analyze Resume Error: $e');
      throw Exception('Failed to analyze resume: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Exception _createDetailedException(dynamic error, String rawResponse) {
    final buffer = StringBuffer('Analysis failed:\n$error');
    if (_lastCleanedResponse != null) {
      buffer.write('\n\nCleaned Response:\n$_lastCleanedResponse');
    } else {
      buffer.write(
        '\n\nRaw Response (truncated):\n${_truncateResponse(rawResponse)}',
      );
    }
    return Exception(buffer.toString());
  }

  String _buildStrictAnalysisPrompt({
    required String resumeText,
    required String jobDescription,
  }) {
    return """
You are an AI-powered resume analyzer with expertise in ATS optimization, job market trends, and resume best practices. Analyze the provided resume (and optional job description) to produce a structured JSON report with detailed, actionable insights. Follow the schema below exactly, ensuring all fields are populated with relevant, concise, and user-friendly feedback optimized for UI display. The 'summary' should be a detailed overview (at least 50 words) of strengths and weaknesses. The 'content' field in 'sections' should be an array of strings for bullet-point display (e.g., multiple projects or items).

📐 Output JSON Schema
{
  "summary": "string",
  "success": boolean,
  "metadata": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "address": "string",
    "resumeType": "string",
    "experienceLevel": "string",
    "industry": "string"
  },
  "atsScore": integer,
  "grammarScore": integer,
  "readabilityScore": integer,
  "verbQualityScore": integer,
  "formatScore": integer,
  "jobMatchScore": integer,
  "coherenceScore": integer,
  "keywordDensityScore": integer,
  "generalSuggestions": ["string"],
  "atsOptimizationTips": ["string"],
  "actionVerbSuggestions": ["string"],
  "chronologyWarnings": ["string"],
  "missingKeywords": ["string"],
  "matchedKeywords": ["string"],
  "grammarIssues": ["string"],
  "atsOptimizationExamples": ["string"],
  "sections": [
    {
      "name": "string",
      "content": ["string"],
      "score": integer,
      "feedback": "string",
      "suggestions": ["string"],
      "improvementExamples": ["string"]
    }
  ],
  "confidenceScore": integer,
  "rawResponse": "string",
  "timestamp": "string"
}

🛠️ Guidelines
- Summary: Detailed (min 50 words), e.g., "Strong MERN stack skills with clear project examples, but lacks quantifiable metrics and ATS optimization. Improve keyword density and formatting for better compatibility."
- Scoring: 0-100, deduct for issues (e.g., ATS: -10 for low keywords, Grammar: -5 for typos).
- Feedback: Max 3 items per list, specific (e.g., "Add 'Agile' to Skills"), use fallbacks (e.g., "No issues detected").
- Sections: Include "Objective", "Education", "Technical Skills", "Projects", "Certifications", "Achievements", "Other". Use standard names. 'content' as array for bullet points.
- Confidence: 50-100, lower for poor data (e.g., empty resume).
- Timestamp: ISO 8601 (e.g., "2025-05-21T23:00:00Z").
- Output: Valid JSON, no extra text.

📝 Inputs
Job Description: ${jobDescription.trim().isEmpty ? 'Not provided. Infer software engineering requirements (e.g., Python, Agile, DevOps).' : jobDescription.trim()}
Resume Content: ${resumeText.trim().isEmpty ? 'Not provided. Assume mid-level software engineer resume.' : resumeText.trim()}
""";
  }

  Future<http.Response> _sendAnalysisRequest(
    String apiKey,
    String prompt,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: _buildHeaders(apiKey),
            body: jsonEncode(_buildRequestBody(prompt)),
          )
          .timeout(const Duration(seconds: 180));
      debugPrint('API request sent, status: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('Send Request Error: $e');
      throw Exception('Failed to send API request: $e');
    }
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
              "Return only valid JSON without text, formatting, or code fences.",
        },
        {"role": "user", "content": prompt},
      ],
      "response_format": {"type": "json_object"},
      "temperature": 0.1,
    };
  }

  model.AnalysisModel _parseAndCleanResponse(http.Response response) {
    if (response.statusCode != 200) {
      debugPrint(
        'API Error: ${response.statusCode}, Body: ${_truncateResponse(response.body)}',
      );
      throw Exception(
        'API Error ${response.statusCode}: ${_truncateResponse(response.body)}',
      );
    }

    final cleanedBody = _cleanJsonResponse(response.body);
    _lastCleanedResponse = cleanedBody;

    try {
      final jsonResponse = jsonDecode(cleanedBody) as Map<String, dynamic>;
      debugPrint('Parsed JSON Response: ${jsonEncode(jsonResponse)}');
      final content = _extractContentFromResponse(jsonResponse);
      final analysisJson = jsonDecode(content) as Map<String, dynamic>;
      return _parseValidatedAnalysis(analysisJson);
    } catch (e) {
      debugPrint('Parse Response Error: $e');
      throw Exception('Failed to parse response: $e\nCleaned: $cleanedBody');
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
      debugPrint('Invalid OpenRouter response: $jsonResponse');
      throw Exception('Invalid response: choices[0].message.content missing.');
    } catch (e) {
      debugPrint('Extract Content Error: $e');
      throw Exception('Invalid response structure: $e');
    }
  }

  String _cleanJsonResponse(String rawResponse) {
    try {
      String cleaned = rawResponse.replaceAll(RegExp(r'```(json)?'), '').trim();
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch == null) {
        throw FormatException('No valid JSON found in response');
      }
      return jsonMatch.group(0)!;
    } catch (e) {
      debugPrint('Clean JSON Error: $e');
      throw FormatException('Failed to clean JSON: $e');
    }
  }

  model.AnalysisModel _parseValidatedAnalysis(Map<String, dynamic> content) {
    try {
      debugPrint('Parsing Analysis JSON: ${jsonEncode(content)}');
      final analysis = model.AnalysisModel.fromJson(content);
      debugPrint('Parsed AnalysisModel: ${jsonEncode(analysis.toJson())}');
      return analysis;
    } catch (e) {
      debugPrint('Parse Analysis Error: $e');
      throw Exception('Failed to parse analysis JSON: $e');
    }
  }

  String _attemptToClean(String rawResponse) {
    try {
      return _cleanJsonResponse(rawResponse);
    } catch (e) {
      debugPrint('Attempt Clean Error: $e');
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
