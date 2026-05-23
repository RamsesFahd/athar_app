import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

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
      {required String prompt, required String systemInstruction, Uint8List? imageBytes}) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'Rawi couldn’t respond right now. Please try again.');
    }

    // إعادة تعريف الموديل مع التعليمات البرمجية لضمان الشخصية واللغة
    final modelWithInstructions = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          if (imageBytes != null) DataPart('image/jpeg', imageBytes),
        ])
      ];
      final response = await modelWithInstructions.generateContent(content);
      return response.text?.trim().isNotEmpty == true
          ? response.text!.trim()
          : "عذراً، لم أفهم ذلك.";
    } on GenerativeAIException catch (e) {
      print('❌ Gemini API error: ${e.message}');
      throw Exception('Rawi couldn’t respond right now. Please try again.');
    } catch (e) {
      print('❌ Unexpected Gemini error: $e');
      throw Exception('Rawi couldn’t respond right now. Please try again.');
    }
  }
}
