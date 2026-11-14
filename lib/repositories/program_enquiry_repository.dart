import '../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../models/program_enquiry.dart';

/// Contract for submitting pillar-page enquiries and internship applications.
/// A Firebase (or API) implementation replaces
/// [PendingBackendProgramEnquiryRepository] in the backend phase.
abstract class ProgramEnquiryRepository {
  Future<SubmissionResult> submit(ProgramEnquiry enquiry);
}

/// Validates the flow end to end but sends nothing, and reports that
/// honestly so the UI never shows a false success.
class PendingBackendProgramEnquiryRepository implements ProgramEnquiryRepository {
  const PendingBackendProgramEnquiryRepository();

  @override
  Future<SubmissionResult> submit(ProgramEnquiry enquiry) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const SubmissionResult(SubmissionStatus.backendNotConnected);
  }
}
