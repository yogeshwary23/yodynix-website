import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/site_config.dart';
import '../models/contact_enquiry.dart';

/// Contract for submitting enquiries, so the contact UI does not depend on
/// where the data goes.
abstract class ContactRepository {
  Future<SubmissionResult> submit(ContactEnquiry enquiry);
}

/// Sends enquiries to the YODYNIX contact Worker, which emails them to the
/// team. Reports success only when the Worker confirms the mail server
/// accepted the message.
class ApiContactRepository implements ContactRepository {
  const ApiContactRepository({this.endpoint = ContactConfig.enquiryApiUrl});

  final String endpoint;

  static const _timeout = Duration(seconds: 35);

  @override
  Future<SubmissionResult> submit(ContactEnquiry enquiry) async {
    if (endpoint.isEmpty) return const SubmissionResult(SubmissionStatus.backendNotConnected);
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            // `website` is the honeypot: always empty from a real visitor.
            body: jsonEncode({...enquiry.toMap(), 'website': ''}),
          )
          .timeout(_timeout);
      final body = jsonDecode(response.body);
      final ok = response.statusCode == 200 && body is Map && body['ok'] == true;
      return SubmissionResult(ok ? SubmissionStatus.success : SubmissionStatus.failure);
    } catch (_) {
      return const SubmissionResult(SubmissionStatus.failure);
    }
  }
}

/// Validates the flow end to end but sends nothing, and says so to the UI.
/// Useful for previews without a backend.
class PendingBackendContactRepository implements ContactRepository {
  const PendingBackendContactRepository();

  @override
  Future<SubmissionResult> submit(ContactEnquiry enquiry) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const SubmissionResult(SubmissionStatus.backendNotConnected);
  }
}
