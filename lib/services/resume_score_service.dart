import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ResumeScoreService {
  static const _apiKey = 'aff_7577ba79456d7d65f7c8fee6327267f755053f80';
  static const _endpoint = 'https://api.affinda.com/v2/resumes/score';

  static Future<Map<String, dynamic>> analyzeResume(
    Uint8List fileBytes,
    String filename,
  ) async {
    final request =
        http.MultipartRequest('POST', Uri.parse(_endpoint))
          ..headers['Authorization'] = 'Bearer $_apiKey'
          ..files.add(
            http.MultipartFile.fromBytes('file', fileBytes, filename: filename),
          );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze resume. (${response.statusCode})');
    }
  }
}
