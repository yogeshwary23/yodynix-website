/// Free or paid opportunity preference on an internship application.
enum InternshipType {
  free('Free'),
  paid('Paid');

  const InternshipType(this.label);

  final String label;
}

/// An internship application / registration of interest. Ready to be
/// serialised for a future backend via [toMap]; nothing is stored locally.
class InternshipApplication {
  const InternshipApplication({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.institution,
    required this.education,
    required this.program,
    required this.type,
    this.experience,
    this.message,
  });

  final String fullName;
  final String email;
  final String mobile;

  /// College / institution name.
  final String institution;

  /// Current education level, e.g. "Undergraduate student".
  final String education;

  /// Preferred programme title.
  final String program;
  final InternshipType type;
  final String? experience;
  final String? message;

  Map<String, Object?> toMap() => {
    'kind': 'internship_application',
    'fullName': fullName,
    'email': email,
    'mobile': mobile,
    'institution': institution,
    'education': education,
    'program': program,
    'internshipType': type.name,
    'experience': experience,
    'message': message,
  };
}
