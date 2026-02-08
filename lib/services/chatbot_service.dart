import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mri_context.dart';

class AiMedicalChatService {
  static const String _endpoint = 'http://10.0.2.2:11434/api/generate';

  static String _systemPrompt() {
    if (!MRIContext.hasResult) {
      return '''
You are a medical information assistant for Brain MRI.

RULES:
- Do NOT say you are a doctor
- Do NOT introduce yourself
- Keep answers short (2–4 sentences)
- Use simple language
- Only discuss Brain MRI
- If no MRI result is available, say it clearly
- Encourage consulting a real doctor
''';
    }

    final probs = MRIContext.probabilities!.entries
        .map((e) =>
            '${e.key}: ${((e.value as num) * 100).toStringAsFixed(1)}%',)
        .join(', ');

    return '''
You are a medical information assistant for Brain MRI.

MRI RESULT:
- Predicted finding: ${MRIContext.predictedLabel}
- Model confidence: ${(MRIContext.confidence! * 100).toStringAsFixed(1)}%
- Class probabilities: $probs

GUIDELINES:
- Do NOT diagnose or claim certainty
- Explain what the result may suggest
- Be calm and reassuring
- Keep responses short and clear
- Encourage medical consultation
''';
  }

  static Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'qwen2.5:7b-instruct',
          'stream': false,
          'prompt': '''
SYSTEM:
${_systemPrompt()}

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
    } catch (_) {
      return 'Unable to connect to AI service.';
    }
  }
}
