import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = 'xai-YvhELVKEw8rpM7yCSTpAVtU9UsbcRuzdHqNHFi5d0QONmgZgPePNwOUbRu3sbPbphfHjiIL5rXQjEtpv';

  static const String _url = 'https://api.x.ai/v1/chat/completions';

  Future<String> generateCourseInsights({
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    if (reviews.isEmpty) {
      return 'No reviews yet to summarize.';
    }

    final reviewText = reviews
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. "${e.value}"')
        .join('\n');

    final prompt = '''
You are an AI assistant for a university course review platform called SabanciInsight.

Course: "$courseTitle"
Average Rating: ${avgRating.toStringAsFixed(1)}/5

Student Reviews:
$reviewText

Based on these reviews, write a concise 2-3 sentence summary of what students think about this course.

Mention themes like:
- workload
- grading
- difficulty
- instructor quality
- usefulness
- exams/projects

Be objective and helpful.

Only return the summary text.
''';

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'grok-3-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You summarize university course reviews clearly and concisely.'
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content']
          .toString()
          .trim();
    } else {
      throw Exception(
        'xAI API Error: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
