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
  final bool isStandaloneTranscriptUpload;

  const VerifyEnrollmentScreen({
    super.key,
    required this.courseCode,
    required this.courseName,
    this.fromReviewFlow = true,
    this.isStandaloneTranscriptUpload = false,
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

  bool _loadingSavedTranscript = true;
  EnrollmentVerificationItem? _savedSourceForCourse;
  bool _hasAnySavedVerification = false;
  /// User chose to upload a new PDF despite having a matching saved transcript.
  bool _forceNewUpload = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTranscriptState();
  }

  Future<void> _loadSavedTranscriptState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _loadingSavedTranscript = false;
          _savedSourceForCourse = null;
          _hasAnySavedVerification = false;
        });
      }
      return;
    }
    if (widget.isStandaloneTranscriptUpload) {
      try {
        final items = await _service.listForUser(user.uid);
        if (!mounted) return;
        setState(() {
          _loadingSavedTranscript = false;
          _savedSourceForCourse = null;
          _hasAnySavedVerification = items.isNotEmpty;
        });
      } catch (e) {
        debugPrint('Saved transcript lookup failed: $e');
        if (!mounted) return;
        setState(() {
          _loadingSavedTranscript = false;
          _savedSourceForCourse = null;
          _hasAnySavedVerification = false;
        });
      }
      return;
    }
    try {
      final items = await _service.listForUser(user.uid);
      final merged = EnrollmentVerificationService.mergedCourseCodes(items);
      final canReuse = TranscriptCourseExtractor.listContainsCourse(
        merged,
        widget.courseCode,
      );
      final source = canReuse
          ? EnrollmentVerificationService.latestItemContainingCourse(
              items,
              widget.courseCode,
            )
          : null;
      if (!mounted) return;
      setState(() {
        _loadingSavedTranscript = false;
        _hasAnySavedVerification = items.isNotEmpty;
        _savedSourceForCourse = source;
      });
    } catch (e) {
      debugPrint('Saved transcript lookup failed: $e');
      if (!mounted) return;
      setState(() {
        _loadingSavedTranscript = false;
        _savedSourceForCourse = null;
        _hasAnySavedVerification = false;
      });
    }
  }

  void _continueWithSavedTranscript() {
    final user = FirebaseAuth.instance.currentUser;
    final source = _savedSourceForCourse;
    if (user == null || source == null) return;

    final email = user.email ?? user.uid;
    final recordedAt = source.createdAt ?? DateTime.now();

    Navigator.pushNamed(
      context,
      AppRoutes.verificationSuccess,
      arguments: VerificationSuccessRouteArgs(
        documentId: source.id,
        courseCode: widget.courseCode,
        courseName: widget.courseName,
        fileName: source.fileName,
        userEmail: email,
        recordedAt: recordedAt,
        extractedCourseCodes: source.extractedCourseCodes,
      ),
    );
  }

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
          content: Text('Could not read the PDF. Please try again.'),
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
      debugPrint('Transcript parse error: $e');
      setState(() {
        _codesFromPdf = [];
        _parseError =
            'Could not read text from this PDF. Try another text-based transcript.';
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
        const SnackBar(content: Text('Select a PDF first (file content is required).')),
      );
      return;
    }

    final codes = _codesFromPdf;
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No course codes were found. Use a text-based (Banner) transcript PDF.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final standalone = widget.isStandaloneTranscriptUpload;
      final item = EnrollmentVerificationItem(
        id: '',
        courseCode: standalone ? '-' : widget.courseCode,
        courseName: standalone ? 'Transcript' : widget.courseName,
        fileName: _pickedFileName!,
        fileSizeBytes: _pickedSizeBytes ?? 0,
        createdBy: user.uid,
        status: 'verified',
        extractedCourseCodes: codes,
      );
      final docId = await _service.replaceTranscriptForUser(user.uid, item);
      if (!mounted) return;

      final email = user.email ?? user.uid;
      final recordedAt = DateTime.now();

      if (standalone) {
        Navigator.pushReplacementNamed(context, AppRoutes.transcript);
        return;
      }

      final courseOk = TranscriptCourseExtractor.listContainsCourse(
        codes,
        widget.courseCode,
      );

      if (courseOk) {
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
      } else {
        final messenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Transcript saved. ${widget.courseCode} was not found in this file — '
              'you cannot post a review for that course until it appears on your saved transcript.',
            ),
          ),
        );
        nav.pop();
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint('Enrollment verification save error (${e.code}): ${e.message}');
      final message = e.code == 'permission-denied'
          ? 'Verification could not be saved. Please try again later.'
          : 'Something went wrong while saving. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Enrollment verification save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification could not be saved. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg =
        isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);

    if (_loadingSavedTranscript) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    final source = _savedSourceForCourse;
    if (source != null &&
        !_forceNewUpload &&
        !widget.isStandaloneTranscriptUpload) {
      return Scaffold(
        backgroundColor: pageBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      courseCode: widget.courseCode,
                      courseName: widget.courseName,
                      isStandalone: widget.isStandaloneTranscriptUpload,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF22C55E), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.4)
                                : const Color(0x10000000),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF4ADE80),
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Saved transcript',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.courseCode} is already listed on the '
                            'transcript you uploaded earlier. You do not need to '
                            'upload the PDF again — you can continue with the '
                            'saved data.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.82)
                                  : const Color(0xFF374151),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Source file: ${source.fileName}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.55)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _continueWithSavedTranscript,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Continue with saved transcript',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _forceNewUpload = true);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF2563EB),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Upload updated transcript',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? const Color(0xFF93C5FD) : null,
                        ),
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

    return Scaffold(
      backgroundColor: pageBg,
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
                    isStandalone: widget.isStandaloneTranscriptUpload,
                  ),
                  const SizedBox(height: 20),
                  const _ProgressStepsCard(),
                  const SizedBox(height: 16),
                  if (widget.isStandaloneTranscriptUpload &&
                      _hasAnySavedVerification) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF172554)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Text(
                        'You already have a transcript on file. Saving a new PDF '
                        'replaces it completely.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFF1E3A8A),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (_forceNewUpload && source != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF172554)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Text(
                        'When you save a new PDF, your previous transcript data '
                        'is removed. Only the course list from this file remains.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFBFDBFE)
                              : const Color(0xFF1E3A8A),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  if (!widget.isStandaloneTranscriptUpload &&
                      _hasAnySavedVerification &&
                      source == null &&
                      !_forceNewUpload) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF422006)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFF97316)
                              : const Color(0xFFFDBA74),
                        ),
                      ),
                      child: Text(
                        '${widget.courseCode} is not on your saved transcript. '
                        'Upload a PDF that includes this course. A new upload '
                        'replaces your stored transcript entirely.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFFED7AA)
                              : const Color(0xFF9A3412),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    widget.isStandaloneTranscriptUpload
                        ? 'Select your official transcript PDF. Text-based (Banner) '
                            'files are scanned for course codes. Saving replaces '
                            'any transcript you stored earlier.'
                        : 'Upload your official transcript PDF. Text-based (Banner) '
                            'PDFs are scanned for course codes. You can save even '
                            'if ${widget.courseCode} is not listed, but you can '
                            'only post a review after that course appears on your '
                            'saved transcript.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.78)
                          : const Color(0xFF374151),
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
                    LinearProgressIndicator(
                      color: theme.colorScheme.primary,
                      backgroundColor: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE5E7EB),
                    ),
                  ],
                  if (_parseError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _parseError!,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFB91C1C),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (!widget.isStandaloneTranscriptUpload) ...[
                    _CourseCodesPanel(
                      codesFromPdf: _codesFromPdf,
                      targetCourse: widget.courseCode,
                    ),
                    const SizedBox(height: 14),
                  ],
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
                              'Save transcript',
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
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? const Color(0xFF93C5FD) : null,
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTarget
              ? const Color(0xFF22C55E)
              : (isDark ? const Color(0xFF404040) : const Color(0xFFE5E7EB)),
          width: hasTarget ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0x10000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course codes from transcript',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasTarget
                ? '$targetCourse is listed — you can complete verification for this course.'
                : '$targetCourse is not listed yet — you can still save this '
                    'transcript, but you cannot post a review for this course '
                    'until it appears here.',
            style: TextStyle(
              fontSize: 13,
              color: hasTarget
                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                  : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 10),
          if (codesFromPdf.isEmpty)
            Text(
              'No codes yet. Use a text-based transcript PDF.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
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
                  label: Text(
                    c,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  backgroundColor: isTarget
                      ? (isDark
                          ? const Color(0xFF14532D)
                          : const Color(0xFFDCFCE7))
                      : (isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFF3F4F6)),
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
    this.isStandalone = false,
  });

  final String courseCode;
  final String courseName;
  final bool isStandalone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStandalone ? 'Upload transcript' : 'Verify Enrollment',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isStandalone
                    ? 'Official Banner PDF — course codes are read automatically.'
                    : 'Course: $courseCode — $courseName',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : const Color(0xFF6B7280),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color(0x14000000),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = isActive
        ? const Color(0xFF2196F3)
        : (isDark ? const Color(0xFF374E7C) : const Color(0xFFBFDBFE));
    final textColor = isActive
        ? (isDark ? Colors.white : const Color(0xFF111827))
        : (isDark ? Colors.white60 : const Color(0xFF6B7280));
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.48) : const Color(0xFF6B7280);
    final stepNumColor =
        isActive ? Colors.white : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8));
    final connectorColor =
        isDark ? const Color(0xFF444444) : const Color(0xFFD1D5DB);

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
                    color: stepNumColor,
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
                  color: connectorColor,
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
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = fileName != null
        ? const Color(0xFF2563EB)
        : (isDark ? const Color(0xFF525252) : const Color(0xFFD1D5DB));
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final hintColor =
        isDark ? Colors.white.withValues(alpha: 0.45) : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: fileName != null ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0x10000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 56,
                color: fileName != null
                    ? const Color(0xFF60A5FA)
                    : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2196F3)),
              ),
              const SizedBox(height: 6),
              Text(
                fileName ?? 'Tap to select PDF',
                style: TextStyle(
                  fontSize: fileName != null ? 16 : 22,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (fileName == null) ...[
                const SizedBox(height: 4),
                Text(
                  'Official transcript export only',
                  style: TextStyle(
                    fontSize: 14,
                    color: hintColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFD1D5DB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0x10000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const RequirementItem(
            icon: Icons.picture_as_pdf_rounded,
            text: 'Format: PDF only',
          ),
          const SizedBox(height: 6),
          const RequirementItem(
            icon: Icons.badge_rounded,
            text: 'Must show your name and Student ID',
          ),
          const SizedBox(height: 6),
          const RequirementItem(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF374151);
    final body = isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF111827);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.5, color: body),
          ),
        ),
      ],
    );
  }
}
