import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  final String _apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  final String _modelName =
      (dotenv.env['GEMINI_MODEL'] ?? 'gemini-3.1-flash-lite-preview').trim();

  GeminiService() {
    // التحقق من وجود المفتاح في التيرمنال
    if (_apiKey.isEmpty) {
      print("❌ Error: GEMINI_API_KEY is missing from .env file!");
    } else {
      print(
          "✅ Gemini API Key loaded successfully: ${_apiKey.substring(0, 5)}...");
      print("🤖 Gemini model: $_modelName");
    }
  }

  // هذه الدالة يجب أن تكون خارج أقواس الـ Constructor لكي يراها التطبيق
  Future<String> getResponse(
      {required String prompt, required String systemInstruction}) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'GEMINI_API_KEY is empty. Please check your .env file and restart the app.');
    }

    // إعادة تعريف الموديل مع التعليمات البرمجية لضمان الشخصية واللغة
    final modelWithInstructions = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    try {
      final content = [Content.text(prompt)];
      final response = await modelWithInstructions.generateContent(content);
      return response.text?.trim().isNotEmpty == true
          ? response.text!.trim()
          : "عذراً، لم أفهم ذلك.";
    } on GenerativeAIException catch (e) {
      print('❌ Gemini API error: ${e.message}');
      throw Exception('Gemini API error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected Gemini error: $e');
      throw Exception('Unexpected Gemini error: $e');
    }
  }
}
