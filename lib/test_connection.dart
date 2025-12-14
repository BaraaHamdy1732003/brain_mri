// test_connection.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Ollama connection from Dart...\n');

  final testUrls = [
    'http://localhost:11434/api/tags',
    'http://127.0.0.1:11434/api/tags',
    'http://0.0.0.0:11434/api/tags',
  ];

  for (var url in testUrls) {
    print('Testing: $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 3));
      print('✅ Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Body: ${response.body.substring(0, 100)}...');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
    print('---\n');
  }

  // Test actual generate endpoint
  print('🧪 Testing generate endpoint...');
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:11434/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'gemma3:1b',
        'prompt': 'Test connection',
        'stream': false,
      }),
    ).timeout(Duration(seconds: 5));

    print('✅ Generate status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${data['response']}');
    }
  } catch (e) {
    print('❌ Generate error: $e');
  }
}