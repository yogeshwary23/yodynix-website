/// Project enquiry captured by the contact form. Ready to be serialised for a
/// future Firebase / API backend via [toMap].
class ContactEnquiry {
  const ContactEnquiry({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.service,
    required this.description,
    required this.preferredContactMethod,
    this.businessName,
    this.budget,
    this.timeToComplete,
  });

  final String fullName;
  final String? businessName;
  final String email;
  final String mobile;
  final String service;
  final String? budget;
  final String description;
  final String preferredContactMethod;

  /// How long the visitor spent on the form; the backend uses it as a
  /// light anti-spam signal.
  final Duration? timeToComplete;

  Map<String, Object?> toMap() => {
    'fullName': fullName,
    'businessName': businessName,
    'email': email,
    'mobile': mobile,
    'service': service,
    'budget': budget,
    'description': description,
    'preferredContactMethod': preferredContactMethod,
    if (timeToComplete != null) 'elapsedMs': timeToComplete!.inMilliseconds,
  };
}

enum SubmissionStatus { success, backendNotConnected, failure }

class SubmissionResult {
  const SubmissionResult(this.status, [this.message, this.confirmationSent = false]);

  final SubmissionStatus status;
  final String? message;

  /// Whether the server confirms that a confirmation email was accepted
  /// for delivery to the submitter. False when unknown.
  final bool confirmationSent;
}
