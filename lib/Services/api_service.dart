import 'dart:convert';
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

      final prompt = _buildStrictAnalysisPrompt(
        resumeText: extractedText,
        jobDescription: jobDescription,
      );

      final response = await _sendAnalysisRequest(apiKey, prompt);
      _lastRawResponse = response.body;

      final analysis = _parseAndCleanResponse(response);
      _lastAnalysis = analysis;
      return analysis;
    } catch (e) {
      _lastError = e.toString();
      throw _createDetailedException(e, _lastRawResponse ?? 'No response');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Exception _createDetailedException(dynamic error, String rawResponse) {
    final buffer = StringBuffer('Analysis failed: $error');
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
You are an AI-powered resume analyzer with expertise in ATS optimization, job market trends, and resume best practices. Analyze the provided resume (and optional job description) to produce a structured JSON report with detailed, actionable insights. Follow the schema below exactly, ensuring all fields are populated with relevant, concise, and user-friendly feedback optimized for UI display. All feedback lists (e.g., generalSuggestions, atsOptimizationTips) must include as many relevant items as necessary, with no arbitrary limits, but keep each item concise for UI readability. The 'summary' must be a detailed overview (at least 50 words) of strengths and weaknesses.

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
- **Summary**: Provide a detailed overview (min 50 words) of the resume's strengths and weaknesses, e.g., "Strong MERN stack skills with clear project examples, but lacks quantifiable metrics and ATS optimization. Improve keyword density and formatting for better compatibility." Highlight key areas for improvement and positive aspects.
- **Success**: Set to `true` if the resume is analyzable and contains sufficient data; `false` if the resume is empty, malformed, or lacks critical information (e.g., no experience or skills).
- **Metadata**:
  - Extract `name`, `email`, `phone`, `address` from the resume. Use placeholders (e.g., "Not provided") if missing.
  - `resumeType`: Identify format (e.g., "Chronological", "Functional", "Hybrid") based on structure.
  - `experienceLevel`: Infer from content (e.g., "Entry-level", "Mid-level", "Senior") based on years of experience or role complexity.
  - `industry`: Infer from skills, roles, or projects (e.g., "Software Development", "Finance"). Use "General" if unclear.
- **Scoring (0-100)**:
  - `atsScore`: Deduct -10 for missing keywords, -5 for poor formatting (e.g., non-standard fonts), -5 for dense paragraphs.
  - `grammarScore`: Deduct -5 per grammar issue (e.g., typos, incorrect tense). Use tools like spell-check or grammar analysis.
  - `readabilityScore`: Deduct -5 for long sentences (>25 words), -5 for complex words, -10 for dense text blocks.
  - `verbQualityScore`: Deduct -5 for weak verbs (e.g., "did", "worked"), -5 for passive voice.
  - `formatScore`: Deduct -5 for inconsistent formatting (e.g., mixed bullet styles), -10 for cluttered layout.
  - `jobMatchScore`: Deduct -10 for missing job-specific keywords, -5 for irrelevant experience. Score 0 if no job description provided.
  - `coherenceScore`: Deduct -5 for unclear role transitions, -5 for missing context in descriptions.
  - `keywordDensityScore`: Deduct -5 for low keyword frequency, -10 for missing critical skills.
  - Ensure deductions are cumulative but cap scores at 0.
- **Feedback Lists**:
  - Include all relevant feedback without arbitrary limits.
  - `generalSuggestions`: Broad improvements (e.g., "Add quantifiable metrics to projects", "Use consistent font sizes").
  - `atsOptimizationTips`: ATS-specific advice (e.g., "Include 'Agile' in Skills", "Avoid headers/footers for contact info").
  - `actionVerbSuggestions`: Strong verbs to replace weak ones (e.g., "Replace 'did' with 'developed'", "Use 'optimized' instead of 'worked on'").
  - `chronologyWarnings`: Issues with timeline (e.g., "Unexplained gap between jobs in 2022-2023", "Inconsistent date formats").
  - `missingKeywords`: Skills from job description not in resume (e.g., "DevOps", "Scrum").
  - `matchedKeywords`: Skills in resume matching job description (e.g., "Python", "JavaScript").
  - `grammarIssues`: List all grammar errors (e.g., "Typo: 'managment' should be 'management'", "Incorrect tense: 'leads' should be 'led'").
  - `atsOptimizationExamples`: Examples of improved phrasing (e.g., "Change 'worked on code' to 'Developed Python scripts for automation'").
- **Sections**:
  - Dynamically extract all sections from the resume (e.g., "Education", "Work Experience", "Skills", "Projects"). Do not assume predefined sections.
  - For each section:
    - `name`: Use the exact section title from the resume (e.g., "Professional Experience" instead of "Work Experience").
    - `content`: List all items as bullet points (e.g., ["Developed web app using React", "Led team of 5 engineers"]).
    - `score`: 0-100, based on relevance, clarity, and ATS compatibility. Deduct -5 for vague items, -10 for missing metrics.
    - `feedback`: Summarize quality (e.g., "Strong technical skills listed but lacks specific frameworks").
    - `suggestions`: Specific improvements (e.g., "Add 'Django' to Skills", "Quantify project impact").
    - `improvementExamples`: Rewritten examples (e.g., "Change 'built app' to 'Developed scalable app using Node.js'").
  - If a section is missing (e.g., no "Skills"), include it with empty `content`, low `score`, and feedback like "Section missing; consider adding."
- **Confidence**: 50-100, based on data quality. Set to 50 for empty or incomplete resumes, 75 for partial data, 90-100 for detailed resumes.
- **RawResponse**: Include the original resume text as a string for reference.
- **Timestamp**: Current time in ISO 8601 format (e.g., "2025-05-22T04:42:00Z").
- **Job Description Handling**:
  - If job description is missing, infer a generic software engineering role with common skills (e.g., Python, Agile, DevOps, JavaScript, SQL).
  - Extract keywords from the job description and compare with resume for `missingKeywords`, `matchedKeywords`, and `jobMatchScore`.
- **Error Handling**:
  - If resume is empty or malformed, set `success` to `false`, provide a `summary` explaining the issue, and populate fields with defaults (e.g., empty lists, low scores).
  - Handle unreadable text or ambiguous sections by noting issues in `generalSuggestions` (e.g., "Resume text unreadable; ensure proper formatting").
- **Output**: Return valid JSON only, with no extra text, comments, or code fences. Ensure all fields are present, even if empty.

📝 Inputs
Job Description: ${jobDescription.trim().isEmpty ? 'Not provided. Infer a mid-level software engineering role with requirements including Python, JavaScript, Agile, DevOps, SQL, and cloud platforms (e.g., AWS, Azure).' : jobDescription.trim()}
Resume Content: ${resumeText.trim().isEmpty ? 'Not provided. Assume a mid-level software engineer resume with 3-5 years of experience, including skills like JavaScript, Python, and React, and sections for Education, Work Experience, and Projects.' : resumeText.trim()}
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
      return response;
    } catch (e) {
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
      throw Exception(
        'API Error ${response.statusCode}: ${_truncateResponse(response.body)}',
      );
    }

    final cleanedBody = _cleanJsonResponse(response.body);
    _lastCleanedResponse = cleanedBody;

    try {
      final jsonResponse = jsonDecode(cleanedBody) as Map<String, dynamic>;
      final content = _extractContentFromResponse(jsonResponse);
      final analysisJson = jsonDecode(content) as Map<String, dynamic>;
      return _parseValidatedAnalysis(analysisJson);
    } catch (e) {
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
      throw Exception('Invalid response: choices[0].message.content missing.');
    } catch (e) {
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
      throw FormatException('Failed to clean JSON: $e');
    }
  }

  model.AnalysisModel _parseValidatedAnalysis(Map<String, dynamic> content) {
    try {
      final analysis = model.AnalysisModel.fromJson(content);
      return analysis;
    } catch (e) {
      throw Exception('Failed to parse analysis JSON: $e');
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
