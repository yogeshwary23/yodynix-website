import '../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../models/internship_application.dart';

/// Contract for submitting internship applications. A real backend
/// implementation (Firebase, API or email service) replaces
/// [PendingBackendInternshipRepository] once one is connected.
abstract class InternshipApplicationRepository {
  /// Whether submissions actually reach YODYNIX. The form says so plainly
  /// when this is false.
  bool get isConnected;

  Future<SubmissionResult> submit(InternshipApplication application);
}

/// No backend is connected yet: validates the flow end to end but sends
/// nothing, and reports that honestly so the UI never shows a false success.
class PendingBackendInternshipRepository implements InternshipApplicationRepository {
  const PendingBackendInternshipRepository();

  @override
  bool get isConnected => false;

  @override
  Future<SubmissionResult> submit(InternshipApplication application) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const SubmissionResult(SubmissionStatus.backendNotConnected);
  }
}
