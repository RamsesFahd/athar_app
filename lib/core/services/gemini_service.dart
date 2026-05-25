import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  final String _apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  final String _modelName =
      (dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash').trim();

  // Caches one GenerativeModel per distinct system instruction so the object
  // (and its underlying HTTP client) is not recreated on every message send.
  final Map<String, GenerativeModel> _modelCache = {};

  GenerativeModel _modelFor(String systemInstruction) {
    return _modelCache.putIfAbsent(
      systemInstruction,
      () => GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction),
      ),
    );
  }

  Future<String> getResponse({
    required String prompt,
    required String systemInstruction,
    Uint8List? imageBytes,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    }

    final model = _modelFor(systemInstruction);

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          if (imageBytes != null) DataPart('image/jpeg', imageBytes),
        ])
      ];
      final response = await model.generateContent(content);
      final text = response.text?.trim() ?? '';
      if (text.isNotEmpty) return text;
      // Empty response — caller should localise this message via l10n.rawiDidNotUnderstand.
      throw Exception('empty_response');
    } on GenerativeAIException catch (_) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    } catch (_) {
      throw Exception("Rawi couldn't respond right now. Please try again.");
    }
  }
}
