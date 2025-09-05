// lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _model;

  // ✅ Use --dart-define for API key (never hardcode keys in production)
  final String _apiKey = const String.fromEnvironment(
    'AIzaSyBy1ioxBU4xP9f1hiRBl0Bg5j6wX-Ux4oc',
  );

  GeminiService() {
    if (_apiKey.isEmpty) {
      debugPrint(
        '⚠️ Gemini API key is missing. Please provide it via --dart-define=GEMINI_API_KEY=your_key_here',
      );
    }
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }

  Future<String> generateInterviewQuestion({
    required String resumeText,
    required String userResponse,
  }) async {
    if (_apiKey.isEmpty) {
      return "❌ Gemini API key is not configured. Please set it up using --dart-define.";
    }

    final prompt = """
You are acting as a job interviewer. 
You have the candidate's resume:

$resumeText

And their most recent answer: "$userResponse"

👉 Your task: Ask ONLY the next interview question.  
- Keep it professional and conversational.  
- Do NOT give feedback, summaries, or commentary.  
- Output must be a single question, nothing else.  
""";

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        return "I couldn't generate the next question. Please try again.";
      }

      // Ensure output ends with "?" for consistency
      return text.endsWith('?') ? text : "$text?";
    } catch (e) {
      debugPrint('❌ Gemini API error: $e');
      return 'I am unable to connect to the interview AI at the moment. Please try again later.';
    }
  }
}
