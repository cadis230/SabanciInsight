import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Extracts likely course codes from a PDF transcript (text-based PDFs only).
/// Scanned/image PDFs return empty unless OCR is added separately.
class TranscriptCourseExtractor {
  TranscriptCourseExtractor._();

  /// Sabancı-style codes: 2–5 letter department + 3 digits (e.g. CS 300, MATH301).
  static final RegExp _codePattern = RegExp(r'\b([A-Z]{2,5})\s*(\d{3})\b');

  static const _noisePrefixes = {
    'THE', 'AND', 'FOR', 'NOT', 'YOU', 'ALL', 'CAN', 'HER', 'WAS', 'ONE',
    'OUR', 'OUT', 'DAY', 'GET', 'HAS', 'HIM', 'HIS', 'HOW', 'ITS', 'LET',
    'PDF', 'PNG', 'HTTP', 'WWW', 'FIG', 'TAB', 'REF', 'VOL', 'ISBN',
  };

  static List<String> extractCourseCodesFromPdf(Uint8List bytes) {
    final doc = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(doc);
      final text = extractor.extractText();
      return parseCourseCodesFromPlainText(text);
    } finally {
      doc.dispose();
    }
  }

  /// Exposed for tests / manual paste flows.
  static List<String> parseCourseCodesFromPlainText(String raw) {
    if (raw.isEmpty) return [];
    final upper = raw.toUpperCase();
    final seen = <String>{};
    final out = <String>[];
    for (final m in _codePattern.allMatches(upper)) {
      final dept = m.group(1)!;
      final num = m.group(2)!;
      if (_noisePrefixes.contains(dept)) continue;
      final code = '$dept$num';
      if (seen.add(code)) out.add(code);
    }
    return out;
  }

  static String normalizeCourseCode(String code) {
    return code.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  static bool listContainsCourse(List<String> codes, String courseCode) {
    final want = normalizeCourseCode(courseCode);
    if (want.isEmpty) return false;
    for (final c in codes) {
      if (normalizeCourseCode(c) == want) return true;
    }
    return false;
  }
}
