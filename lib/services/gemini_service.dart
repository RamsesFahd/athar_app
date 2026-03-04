import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;

  GeminiService() {
    // التحقق من وجود المفتاح في التيرمنال
    if (_apiKey.isEmpty) {
      print("❌ Error: GEMINI_API_KEY is missing from .env file!");
    } else {
      print("✅ Gemini API Key loaded successfully: ${_apiKey.substring(0, 5)}...");
    }
    
    // تعريف الموديل الأساسي
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }// dart run build_runner watch --delete-conflicting-outputs

  // هذه الدالة يجب أن تكون خارج أقواس الـ Constructor لكي يراها التطبيق
  Future<String> getResponse({required String prompt, required String systemInstruction}) async {
    // إعادة تعريف الموديل مع التعليمات البرمجية لضمان الشخصية واللغة
    final modelWithInstructions = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    final content = [Content.text(prompt)];
    final response = await modelWithInstructions.generateContent(content);
    return response.text ?? "عذراً، لم أفهم ذلك.";
  }
}