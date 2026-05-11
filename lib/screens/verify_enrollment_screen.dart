import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'enrollment_route_args.dart';
import 'routes.dart';
import 'models/enrollment_verification_item.dart';
import '../services/enrollment_verification_service.dart';
import '../services/transcript_course_extractor.dart';

class VerifyEnrollmentScreen extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final bool fromReviewFlow;

  const VerifyEnrollmentScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    this.fromReviewFlow = true,
  });

  @override
  State<VerifyEnrollmentScreen> createState() => _VerifyEnrollmentScreenState();
}

class _VerifyEnrollmentScreenState extends State<VerifyEnrollmentScreen> {
  final _service = EnrollmentVerificationService();

  String? _pickedFileName;
  int? _pickedSizeBytes;
  Uint8List? _pdfBytes;
  List<String> _codesFromPdf = [];
  String? _parseError;
  bool _parsing = false;
  bool _submitting = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (!mounted) return;
    if (result == null || result.files.isEmpty) return;

    final f = result.files.single;
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF içeriği okunamadı. Web veya bu cihazda tekrar deneyin '
            '(withData gerekir).',
          ),
        ),
      );
      return;
    }

    setState(() {
      _pickedFileName = f.name;
      _pickedSizeBytes = f.size;
      _pdfBytes = bytes;
      _parseError = null;
      _codesFromPdf = [];
    });
    await _extractCodesFromPdf(bytes);
  }

  Future<void> _extractCodesFromPdf(Uint8List bytes) async {
    setState(() {
      _parsing = true;
      _parseError = null;
    });
    try {
      final codes = TranscriptCourseExtractor.extractCourseCodesFromPdf(bytes);
      if (!mounted) return;
      setState(() {
        _codesFromPdf = codes;
        _parseError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _codesFromPdf = [];
        _parseError = 'PDF metin okunamadı (taranmış PDF olabilir): $e';
      });
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to verify enrollment.')),
      );
      return;
    }
    if (_pickedFileName == null || _pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce PDF seçin (içerik okunmalı).')),
      );
      return;
    }

    final codes = _codesFromPdf;
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transkriptten ders kodu çıkmadı. Metin seçilebilir (Banner) PDF kullanın.',
          ),
        ),
      );
      return;
    }
    if (!TranscriptCourseExtractor.listContainsCourse(
      codes,
      widget.courseCode,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bu sayfa için ders (${widget.courseCode}) PDF metninde bulunamadı. '
            'Doğru transkripti yükleyin.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final item = EnrollmentVerificationItem(
        id: '',
        courseCode: widget.courseCode,
        courseName: widget.courseName,
        fileName: _pickedFileName!,
        fileSizeBytes: _pickedSizeBytes ?? 0,
        createdBy: user.uid,
        status: 'verified',
        extractedCourseCodes: codes,
      );
      final docId = await _service.create(item);
      if (!mounted) return;

      final email = user.email ?? user.uid;
      final recordedAt = DateTime.now();

      Navigator.pushNamed(
        context,
        AppRoutes.verificationSuccess,
        arguments: VerificationSuccessRouteArgs(
          documentId: docId,
          courseCode: widget.courseCode,
          courseName: widget.courseName,
          fileName: _pickedFileName!,
          userEmail: email,
          recordedAt: recordedAt,
          extractedCourseCodes: codes,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? 'Firestore izni yok. Firebase Console → Firestore → Rules: '
              'Bu repodaki firestore.rules dosyasının tamamını yapıştırıp '
              'Publish edin. (Veya: firebase deploy --only firestore:rules)'
          : 'Kayıt hatası (${e.code}): ${e.message ?? ""}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save verification: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    courseCode: widget.courseCode,
                    courseName: widget.courseName,
                  ),
                  const SizedBox(height: 20),
                  const _ProgressStepsCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Resmi transkript PDF’inizi yükleyin. Metin seçilebilir '
                    '(Banner) PDF’lerde ders kodları otomatik taranır. '
                    '${widget.courseCode} çıkan listede yoksa doğrulama tamamlanmaz.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  _UploadArea(
                    fileName: _pickedFileName,
                    onTap: (_submitting || _parsing) ? null : _pickPdf,
                  ),
                  if (_parsing) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  if (_parseError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _parseError!,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _CourseCodesPanel(
                    codesFromPdf: _codesFromPdf,
                    targetCourse: widget.courseCode,
                  ),
                  const SizedBox(height: 14),
                  const _RequirementsCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF93C5FD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Upload and Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text("I'll do this later"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCodesPanel extends StatelessWidget {
  const _CourseCodesPanel({
    required this.codesFromPdf,
    required this.targetCourse,
  });

  final List<String> codesFromPdf;
  final String targetCourse;

  @override
  Widget build(BuildContext context) {
    final targetNorm =
        TranscriptCourseExtractor.normalizeCourseCode(targetCourse);
    final hasTarget = codesFromPdf.any(
      (c) =>
          TranscriptCourseExtractor.normalizeCourseCode(c) == targetNorm,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTarget ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
          width: hasTarget ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transkriptten çıkan ders kodları',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            hasTarget
                ? '$targetCourse listede — doğrulamaya devam edebilirsiniz.'
                : '$targetCourse henüz yok — metin içeren PDF deneyin.',
            style: TextStyle(
              fontSize: 13,
              color: hasTarget
                  ? const Color(0xFF15803D)
                  : const Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 10),
          if (codesFromPdf.isEmpty)
            Text(
              'Henüz kod yok. Metin seçilebilir bir transkript PDF’i yükleyin.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: codesFromPdf.map((c) {
                final isTarget =
                    TranscriptCourseExtractor.normalizeCourseCode(c) ==
                        targetNorm;
                return Chip(
                  label: Text(c),
                  backgroundColor: isTarget
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF3F4F6),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.courseCode,
    required this.courseName,
  });

  final String courseCode;
  final String courseName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Enrollment',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Course: $courseCode — $courseName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStepsCard extends StatelessWidget {
  const _ProgressStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          StepItem(
            stepNumber: 1,
            title: 'Upload Transcript',
            subtitle: 'Official PDF from Banner',
            isActive: true,
            showConnector: true,
          ),
          SizedBox(height: 10),
          StepItem(
            stepNumber: 2,
            title: 'AI Verification',
            subtitle: 'Checking course history',
            showConnector: true,
          ),
          SizedBox(height: 10),
          StepItem(
            stepNumber: 3,
            title: 'Write Review',
            subtitle: 'Share your experience',
          ),
        ],
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  const StepItem({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.isActive = false,
    this.showConnector = false,
  });

  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final circleColor =
        isActive ? const Color(0xFF2196F3) : const Color(0xFFBFDBFE);
    final textColor =
        isActive ? const Color(0xFF111827) : const Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (showConnector) ...[
                const SizedBox(height: 6),
                Container(
                  width: 1.5,
                  height: 30,
                  color: const Color(0xFFD1D5DB),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({
    required this.fileName,
    required this.onTap,
  });

  final String? fileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: fileName != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFD1D5DB),
              width: fileName != null ? 1.8 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 56,
                color: fileName != null
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF2196F3),
              ),
              const SizedBox(height: 6),
              Text(
                fileName ?? 'Tap to select PDF',
                style: TextStyle(
                  fontSize: fileName != null ? 16 : 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (fileName == null) ...[
                const SizedBox(height: 4),
                Text(
                  'Official transcript export only',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements:',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          RequirementItem(
            icon: Icons.picture_as_pdf_rounded,
            text: 'Format: PDF only',
          ),
          SizedBox(height: 6),
          RequirementItem(
            icon: Icons.badge_rounded,
            text: 'Must show your name and Student ID',
          ),
          SizedBox(height: 6),
          RequirementItem(
            icon: Icons.lock_outline_rounded,
            text: 'Data is encrypted and used for verification only',
          ),
        ],
      ),
    );
  }
}

class RequirementItem extends StatelessWidget {
  const RequirementItem({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF374151)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}
