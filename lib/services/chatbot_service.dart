import 'dart:convert';
import 'package:http/http.dart' as http;

class AiMedicalChatService {
  /// Android Emulator → localhost
  static const String _endpoint = 'http://10.0.2.2:11434/api/generate';

  static const String _systemPrompt = '''
You are a medical information assistant for Brain MRI analysis.

RULES:
- Do NOT say you are a doctor
- Do NOT introduce yourself
- Keep answers short (2–4 sentences)
- Use simple, clear language
- Only discuss Brain MRI and related conditions
- Do NOT diagnose or claim certainty
- Recommend consulting a real doctor when appropriate
- If no MRI result is provided, explain that it is required
''';

  static Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'glm-4.6:cloud',
          'stream': false,
          'prompt': '''
SYSTEM:
$_systemPrompt

USER:
$userMessage

ASSISTANT:
''',
        }),
      );

      if (response.statusCode != 200) {
        return 'AI service is unavailable right now.';
      }

      final data = jsonDecode(response.body);

      return data['response']
              ?.toString()
              .trim()
              .replaceAll(RegExp(r'\n{2,}'), '\n') ??
          'No response received.';
    } catch (e) {
      return 'Unable to connect to AI service. Please try again.';
    }
  }
}
