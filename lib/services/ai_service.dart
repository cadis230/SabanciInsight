import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/gemini_api_key.dart';

class AiService {
  static bool get _hasValidKey {
    return geminiApiKey.isNotEmpty &&
        !geminiApiKey.contains('PASTE_YOUR_GEMINI');
  }

  /// Ordered by free-tier RPD (highest first) — see AI Studio → Rate Limit.
  static const _modelIds = [
    'gemini-3.1-flash-lite',
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash-lite',
  ];

  Future<String> generateCourseInsights({
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    if (reviews.isEmpty) {
      return 'No reviews yet to summarize.';
    }

    if (!_hasValidKey) {
      return 'Gemini API anahtarı ayarlanmamış. '
          'lib/config/gemini_api_key.local.example.dart dosyasını '
          'gemini_api_key.local.dart olarak kopyalayıp kendi anahtarınızı yapıştırın.';
    }

    Object? lastError;

    for (final modelId in _modelIds) {
      try {
        return await _generateWithModel(
          modelId: modelId,
          courseTitle: courseTitle,
          reviews: reviews,
          avgRating: avgRating,
        );
      } catch (e) {
        lastError = e;
        debugPrint('AI Service Error ($modelId): $e');
        if (!_shouldTryNextModel(e)) break;
      }
    }

    return _messageForError(lastError ?? 'unknown');
  }

  Future<String> _generateWithModel({
    required String modelId,
    required String courseTitle,
    required List<String> reviews,
    required double avgRating,
  }) async {
    final model = GenerativeModel(
      model: modelId,
      apiKey: geminiApiKey,
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

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Özet oluşturulamadı.';
  }

  bool _shouldTryNextModel(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('not found') ||
        msg.contains('invalid model') ||
        msg.contains('is not supported');
  }

  String _messageForError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('429') ||
        msg.contains('quota') ||
        msg.contains('rate limit') ||
        msg.contains('resource exhausted') ||
        msg.contains('too many requests')) {
      return 'AI günlük kotası doldu. AI Studio → Rate Limit\'ten kontrol edin '
          'veya yarın tekrar deneyin.';
    }
    return 'Özet oluşturulurken bir hata oluştu.';
  }
}
