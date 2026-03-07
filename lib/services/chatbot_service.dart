import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mri_context.dart';

class AiMedicalChatService {
  static const String _endpoint = 'http://10.0.2.2:11434/api/generate';

  static String _systemPrompt() {
    if (!MRIContext.hasResult) {
      return '''
You are a helpful medical information assistant for Brain MRI analysis.

IMPORTANT RULES:
- Never claim to be a doctor or provide medical diagnoses
- Do not introduce yourself or use phrases like "I am an AI assistant"
- Keep all responses brief: 2-4 sentences maximum
- Use simple, clear language that anyone can understand
- Only discuss topics related to Brain MRI and brain health
- If no MRI result is available, clearly state that an MRI needs to be uploaded first
- Always encourage users to consult with a real doctor for medical advice
- Be supportive and informative without being alarmist
''';
    }

    final probs = MRIContext.probabilities!.entries
        .map((e) =>
            '${e.key}: ${((e.value as num) * 100).toStringAsFixed(1)}%',)
        .join(', ');

    return '''
You are a helpful medical information assistant for Brain MRI analysis.

CURRENT MRI RESULTS:
- Primary finding: ${MRIContext.predictedLabel}
- Model confidence: ${(MRIContext.confidence! * 100).toStringAsFixed(1)}%
- Full probability breakdown: $probs

GUIDELINES FOR RESPONSE:
- Explain what this type of finding might mean in general terms
- Do NOT provide a definitive diagnosis
- Maintain a calm, reassuring tone
- Keep responses brief (2-4 sentences)
- Explain medical terms in simple language
- Suggest questions the user might want to ask their doctor
- Always recommend consulting with a healthcare professional
- Do not repeat the full probability breakdown unless asked
''';
  }

  static Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'glm-4.6:cloud',
          'stream': false,
          'prompt': '''
${_systemPrompt()}

USER QUESTION:
$userMessage

Please provide a brief, helpful response following all guidelines above:
''',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode != 200) {
        print('AI service error: ${response.statusCode} - ${response.body}');
        return 'I apologize, but the AI service is temporarily unavailable. Please try again in a moment.';
      }

      final data = jsonDecode(response.body);
      final reply = data['response']?.toString().trim();
      
      if (reply == null || reply.isEmpty) {
        return 'I received an empty response. Please try asking again.';
      }
      
      // Clean up multiple newlines
      return reply.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      
    } catch (e) {
      print('AI Chat Service Error: $e');
      
      if (e.toString().contains('Connection refused')) {
        return 'Unable to connect to the AI service. Please make sure Ollama is running on your computer.';
      } else if (e.toString().contains('Connection timeout')) {
        return 'The connection timed out. Please check your internet connection and try again.';
      } else {
        return 'I encountered a technical issue. Please try again later.';
      }
    }
  }
}