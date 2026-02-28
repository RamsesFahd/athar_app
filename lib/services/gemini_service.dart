import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final geminiServiceProvider = Provider((ref) => GeminiService());

class GeminiService {
  
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<String> getResponse({required String prompt, required String systemInstruction}) async {
    final content = [
      Content.text(systemInstruction), // تمرير سياق المنطقة هنا
      Content.text(prompt),
    ];
    
    final response = await _model.generateContent(content);
    return response.text ?? "عذراً، لم أستطع فهم ذلك.";
  }
}