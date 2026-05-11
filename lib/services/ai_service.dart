import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = 'AIzaSyBUAK5qboGxVI9wEIqiVWM7mfs7-BiRXHs';

  Future<String> generateCourseInsights({
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    if (reviews.isEmpty) {
      return 'No reviews yet to summarize.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'Sen profesyonel bir veri analiz asistanısın. '
          'Sana bir dersin öğrenciler tarafından yapılan yorumlarını vereceğim. '
          'Bu yorumları objektif bir şekilde değerlendirerek kısa, net ve yapıcı (1-2 cümlelik) '
          'bir özet çıkarmanı istiyorum. Sonucu daima Türkçe ver.',
        ),
      );

      final reviewText = reviews.join('\n- ');
      final prompt = 'Ders Adı: $courseTitle\n'
          'Ortalama Puan: $avgRating/5.0\n'
          'Yorumlar:\n- $reviewText';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'Özet oluşturulamadı.';
    } catch (e) {
      print('AI Service Error: $e');
      return 'Özet oluşturulurken bir hata oluştu.';
    }
  }
}
