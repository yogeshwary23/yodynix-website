import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/site_config.dart';
import '../models/contact_enquiry.dart' show SubmissionResult, SubmissionStatus;
import '../models/job_application.dart';

/// Contract for submitting job and internship applications.
abstract class CareersRepository {
  Future<SubmissionResult> submit(JobApplication application);
}

/// Sends applications, résumé included, to the YODYNIX contact Worker's
/// `/api/careers` endpoint. The Worker saves the application and résumé,
/// then emails HR with the résumé attached (retrying later if that email
/// fails). Success is reported only once the Worker confirms the
/// application is saved; otherwise the result carries a message saying
/// what went wrong.
class ApiCareersRepository implements CareersRepository {
  const ApiCareersRepository({this.endpoint = ContactConfig.careersApiUrl});

  final String endpoint;

  // Uploading a few megabytes on a slow connection takes a while.
  static const _timeout = Duration(seconds: 90);

  @override
  Future<SubmissionResult> submit(JobApplication application) async {
    if (endpoint.isEmpty) return const SubmissionResult(SubmissionStatus.backendNotConnected);
    try {
      final resume = application.resume;
      final request = http.MultipartRequest('POST', Uri.parse(endpoint))
        // `website` is the honeypot: always empty from a real visitor.
        ..fields.addAll({...application.toFields(), 'website': ''})
        ..files.add(http.MultipartFile.fromBytes('resume', resume.bytes, filename: resume.name));
      final response = await http.Response.fromStream(await request.send().timeout(_timeout));
      Object? body;
      try {
        body = jsonDecode(response.body);
      } on FormatException {
        body = null;
      }
      if (response.statusCode == 200 && body is Map && body['ok'] == true) {
        return SubmissionResult(SubmissionStatus.success, null, body['confirmationSent'] == true);
      }
      return SubmissionResult(SubmissionStatus.failure, failureMessage(response.statusCode, body));
    } catch (_) {
      return const SubmissionResult(
        SubmissionStatus.failure,
        'We could not reach our application service. Please check your internet connection and try again.',
      );
    }
  }

  /// What to tell the applicant for a refused or failed request.
  static String failureMessage(int status, Object? body) {
    final error = body is Map ? body['error'] : null;
    switch (error) {
      case 'validation_failed':
        final fields = body is Map && body['fields'] is Map ? (body['fields'] as Map).values.join('. ') : '';
        return fields.isEmpty
            ? 'Some details were not accepted. Please check the form and try again.'
            : 'Please check your details: $fields.';
      case 'duplicate_application':
        return 'You have already applied for this position in the last 24 hours. Our hiring team will contact '
            'you by email, so there is no need to apply again.';
      case 'rate_limited':
        return 'Too many attempts in a short time. Please wait a minute and try again.';
      case 'payload_too_large':
        return 'Your résumé is too large. Please upload a PDF, DOC or DOCX file of 5 MB or less.';
      case 'too_fast':
        return 'Please take a moment to review your details, then submit again.';
      case 'origin_not_allowed':
        return 'Online applications are not accepted from this web address. Please apply from yodynix.it.com.';
    }
    if (status == 404) {
      return 'Online applications are temporarily unavailable while our service is being updated. Please try '
          'again shortly.';
    }
    return 'Our application service could not save your application right now ($status). Please try again in a '
        'few minutes.';
  }
}
