import 'package:url_launcher/url_launcher.dart';

class LinkService {
  LinkService._();

  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  }

  static Future<bool> email(String address, {String? subject}) {
    final uri = Uri(scheme: 'mailto', path: address, query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}');
    return launchUrl(uri);
  }

  static Future<bool> call(String phone) {
    return launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), '')));
  }

  static Future<bool> whatsapp(String number, {String? message}) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final query = message == null ? '' : '?text=${Uri.encodeComponent(message)}';
    return open('https://wa.me/$digits$query');
  }
}
