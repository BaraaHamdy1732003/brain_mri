import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MRIApiService {
  static const String _baseUrl = "http://10.0.2.2:5000";

  static Future<Map<String, dynamic>> predict(File imageFile) async {
    final uri = Uri.parse("$_baseUrl/predict");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("API Error: $body");
    }

    return jsonDecode(body);
  }
}
