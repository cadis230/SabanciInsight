import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_step_3/services/transcript_course_extractor.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  group('TranscriptCourseExtractor', () {
    test('parseCourseCodesFromPlainText extracts unique normalized codes', () {
      const raw = '''
      cs 300, MATH301, CS300
      PDF 123 should be ignored.
      ie 201 should be captured.
      ''';

      final codes = TranscriptCourseExtractor.parseCourseCodesFromPlainText(raw);

      expect(codes, ['CS300', 'MATH301', 'IE201']);
    });

    test('listContainsCourse matches regardless of spacing/case', () {
      const codes = ['CS300', 'MATH301'];

      expect(TranscriptCourseExtractor.listContainsCourse(codes, 'cs 300'), isTrue);
      expect(TranscriptCourseExtractor.listContainsCourse(codes, 'math 301'), isTrue);
      expect(TranscriptCourseExtractor.listContainsCourse(codes, 'PHYS101'), isFalse);
    });

    test('extractCourseCodesFromPdf reads text-based PDF content', () {
      final doc = PdfDocument();
      try {
        final page = doc.pages.add();
        final font = PdfStandardFont(PdfFontFamily.helvetica, 12);
        page.graphics.drawString('Completed: CS 300 and MATH301', font);
        final bytes = Uint8List.fromList(doc.saveSync());

        final codes = TranscriptCourseExtractor.extractCourseCodesFromPdf(bytes);
        expect(codes, ['CS300', 'MATH301']);
      } finally {
        doc.dispose();
      }
    });

    test('extractCourseCodesFromPdf throws on invalid PDF bytes', () {
      final invalidBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      expect(
        () => TranscriptCourseExtractor.extractCourseCodesFromPdf(invalidBytes),
        throwsA(anything),
      );
    });
  });
}
