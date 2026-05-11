import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey =
      'xai-YvhELVKEw8rpM7yCSTpAVtU9UsbcRuzdHqNHFi5d0QONmgZgPePNwOUbRu3sbPbphfHjiIL5rXQjEtpv';

  static const String _url =
      'https://api.x.ai/v1/chat/completions';

  Future<String> generateCourseInsights({
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    if (reviews.isEmpty) {
      return 'No reviews yet to summarize.';
    }

    final reviewText = reviews.join('\n');

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "messages": [
          {
            "role": "system",
            "content":
                "You summarize course reviews briefly."
          },
          {
            "role": "user",
            "content":
                "Summarize these reviews for $courseTitle:\n$reviewText"
          }
        ],
        "model": "grok-3-mini",
        "temperature": 0.7
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(response.body);
    }
  }
}
