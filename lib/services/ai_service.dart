import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = 'BURAYA_API_KEY_YAZ';
  static const String _url = 'https://api.anthropic.com/v1/messages';

  /// Reviews listesini alır, Claude'dan özet üretir
  Future<String> generateCourseInsights({
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    if (reviews.isEmpty) return 'No reviews yet to summarize.';

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
Mention key themes (workload, grading, content quality, instructor, etc.) that appear in the reviews.
Be objective and helpful. Only return the summary text, nothing else.
''';

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 300,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    } else {
      throw Exception('AI error: ${response.statusCode}');
    }
  }
}
