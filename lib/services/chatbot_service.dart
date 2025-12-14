import 'dart:io';
import 'dart:convert';
import 'package:http/io_client.dart' as http;

class ChatbotService {
  static const String baseUrl = "http://10.0.2.2:11434/api/generate";

  Future<String> sendMessage(String message,
      {Map<String, dynamic>? contextInfo}) async {

    final cleanedMessage = message.trim().toLowerCase();

    // Create client that BYPASSES system proxy
    final client = HttpClient();
    client.findProxy = (uri) {
  // All local network traffic must avoid VPN
  if (uri.host == '127.0.0.1' ||
      uri.host == 'localhost' ||
      uri.host == '10.0.2.2') {
    return 'DIRECT';
  }

  // Everything else goes through VPN
  return 'PROXY 127.0.0.1:12334';
};


    final ioClient = http.IOClient(client);

    try {
      final systemPrompt = """
You are a professional medical AI assistant specializing in neurology and neuroradiology.
""";

      final enhancedPrompt =
          "$systemPrompt\n\nPatient/User Question: $message\n\nMedical Response:";

      final requestBody = {
        "model": "tinyllama",
        "prompt": systemPrompt,
        "stream": false,
        "context": contextInfo,
        "options": {
          "temperature": 0.3,
          "top_p": 0.9,
        }
      };

      final response = await ioClient.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "No response.";
      } else {
        return "Ollama error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error connecting to Ollama: $e";
    } finally {
      ioClient.close();
    }
  }
}
