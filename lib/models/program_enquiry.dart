/// Enquiry or application captured on a pillar detail page. Ready to be
/// serialised for a future Firebase / API backend via [toMap].
class ProgramEnquiry {
  const ProgramEnquiry({
    required this.kind,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.option,
    required this.message,
    this.extraField,
    this.extraValue,
  });

  /// Which form produced this, e.g. `business_enquiry`.
  final String kind;
  final String fullName;
  final String email;
  final String phone;

  /// Chosen service, technology area or learning track.
  final String option;

  /// Label and value of the page-specific field (business name, education…).
  final String? extraField;
  final String? extraValue;
  final String message;

  Map<String, Object?> toMap() => {
    'kind': kind,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'option': option,
    if (extraField != null) 'extraField': extraField,
    'extraValue': extraValue,
    'message': message,
  };
}
