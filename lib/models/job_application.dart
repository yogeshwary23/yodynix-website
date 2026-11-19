import 'dart:typed_data';

import '../repositories/content/careers_content.dart' show OpeningKind;

/// A résumé chosen in the application form.
class ResumeFile {
  const ResumeFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  static const int maxBytes = 5 * 1024 * 1024;
  static const List<String> extensions = ['pdf', 'doc', 'docx'];

  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';

  String get mimeType => switch (extension) {
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    _ => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  /// "1.2 MB" / "240 KB".
  String get sizeLabel =>
      bytes.length >= 1024 * 1024 ? '${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB' : '${(bytes.length / 1024).ceil()} KB';

  /// Why this file cannot be sent, or null if it can.
  String? get problem {
    if (!extensions.contains(extension)) return 'Please upload a PDF, DOC or DOCX file';
    if (bytes.isEmpty) return 'This file is empty';
    if (bytes.length > maxBytes) return 'Please upload a file of 5 MB or less';
    return null;
  }
}

/// A job or internship application from the Careers page. HR receives it by
/// email with the résumé attached (see `ApiCareersRepository`).
class JobApplication {
  const JobApplication({
    required this.kind,
    required this.position,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.education,
    required this.skills,
    required this.message,
    required this.resume,
    required this.submissionId,
    this.timeToComplete,
  });

  final OpeningKind kind;

  /// The position's title, e.g. "Flutter Development Intern".
  final String position;
  final String fullName;
  final String email;
  final String mobile;
  final String education;
  final String skills;

  /// Optional.
  final String message;
  final ResumeFile resume;

  /// One per form submission: a retried request carries the same id, so
  /// the server stores the application once.
  final String submissionId;

  /// How long the visitor took to fill the form (a simple spam signal).
  final Duration? timeToComplete;

  Map<String, String> toFields() => {
    'kind': kind.name,
    'position': position,
    'fullName': fullName,
    'email': email,
    'mobile': mobile,
    'education': education,
    'skills': skills,
    'message': message,
    'submissionId': submissionId,
    if (timeToComplete != null) 'elapsedMs': '${timeToComplete!.inMilliseconds}',
  };
}
