import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  final String _apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  final String _modelName =
      (dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash').trim();

  Future<String> getResponse({
    required String prompt,
    required String systemInstruction,
    Uint8List? imageBytes,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    }

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
    } on GenerativeAIException catch (_) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    } catch (_) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    }
  }
}
