import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Correct Ollama API endpoint
  static const String baseUrl = "http://localhost:11434/api/generate";

  bool _isMedicalQuestion(String text) {
    final lower = text.toLowerCase();
    final medicalKeywords = [
      'tumor', 'glioma', 'meningioma', 'hemorrhage',
      'stroke', 'seizure', 'symptom', 'diagnosis',
      'treatment', 'mri', 'scan', 'headache',
      'nausea', 'vision', 'weakness', 'numbness'
    ];
    return medicalKeywords.any((k) => lower.contains(k));
  }

  Future<String> sendMessage(String message,
      {Map<String, dynamic>? contextInfo}) async {
    
    if (!_isMedicalQuestion(message)) {
      return "I can only answer medical questions related to brain MRI.";
    }

    try {
      final requestBody = {
        "model": "gemma3:1b",  // <-- your model here
        "prompt": message,
        "stream": false,
        "context": contextInfo,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "No response from model.";
      } else {
        return "Ollama error: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      return "Chat failed: $e\n\nIs Ollama running?";
    }
  }
}
