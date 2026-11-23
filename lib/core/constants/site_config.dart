import 'package:flutter/painting.dart';

import '../../models/social_link.dart';
import '../../models/team_member.dart';

/// Central, editable configuration for brand, contact and team details.
///
/// Everything marked `TODO(yodynix)` is a placeholder waiting for official
/// information. Values left as `null` are shown on the site as
/// "to be announced" and are never replaced with invented details.
class SiteConfig {
  SiteConfig._();

  static const String brandName = 'YODYNIX';
  static const String brandCategory = 'Digital Technology & Innovation Studio';
  /// The official brand tagline: the homepage title (as Google shows it),
  /// the sharing titles and the structured-data slogan.
  static const String tagline = 'Technology. Intelligence. Innovation.';
  static const String shortDescription =
      'A digital technology and innovation studio helping businesses, startups, '
      'entrepreneurs and students turn ideas into practical digital solutions.';

  /// Shows the "YODYNIX" name in text beside the official logo mark.
  /// The logo image itself is never altered.
  static const bool showWordmarkBesideLogo = true;

  static const String website = 'https://www.yodynix.it.com';
}

class ContactConfig {
  ContactConfig._();

  static const String email = 'hr@yodynix.it.com';

  /// Enquiry API (the `yodynix-contact` Cloudflare Worker, see
  /// cloudflare/contact-worker/README.md). Override per build with
  /// `--dart-define=CONTACT_API_URL=...`. Empty means "not connected": the
  /// form then says so honestly and sends nothing.
  static const String enquiryApiUrl = String.fromEnvironment(
    'CONTACT_API_URL',
    defaultValue: 'https://yodynix-contact.yogeshwary231203.workers.dev/api/contact',
  );

  /// Careers API: the same Worker's `/api/careers` endpoint, which emails
  /// job and internship applications to HR with the résumé attached.
  /// Override per build with `--dart-define=CAREERS_API_URL=...`.
  static const String careersApiUrl = String.fromEnvironment(
    'CAREERS_API_URL',
    defaultValue: 'https://yodynix-contact.yogeshwary231203.workers.dev/api/careers',
  );

  /// Official phone numbers in display format; `tel:` links strip the spaces.
  static const List<String> phones = ['+91 97661 82320'];

  // TODO(yodynix): add the WhatsApp number with country code, digits only, e.g. '910000000000'.
  static const String? whatsappNumber = null;

  static const String address = 'Yashada Supreme, 8th Floor, Office No. 802, Moshi, Pune – 412105, Maharashtra, India.';

  /// Short form of [address] for compact spots such as the job cards.
  static const String city = 'Moshi, Pune';

  /// Google Maps directions to [address], resolved by Google from the text
  /// itself rather than hard-coded coordinates.
  static final String directionsUrl = Uri.https('www.google.com', '/maps/dir/', {'api': '1', 'destination': address}).toString();

  /// Budget ranges shown in the enquiry form. Edit to match your pricing.
  static const List<String> budgetOptions = [
    'Not sure yet, need guidance',
    'Starter project (small scope)',
    'Growth project (medium scope)',
    'Advanced project (large scope)',
    'Ongoing / monthly engagement',
  ];

  static const List<String> preferredContactMethods = ['Email', 'Phone Call', 'WhatsApp'];
}

class SocialConfig {
  SocialConfig._();

  // Only configured links are shown. The same URLs are the `sameAs` profiles
  // in web/index.html's structured data (test/seo_test.dart keeps them equal).
  static const List<SocialLink> links = [
    SocialLink(platform: SocialPlatform.instagram, url: 'https://www.instagram.com/yodynix/', handle: '@yodynix'),
    SocialLink(platform: SocialPlatform.facebook, url: 'https://www.facebook.com/people/Yodynix/61592544453906/'),
    SocialLink(platform: SocialPlatform.linkedin, url: 'https://www.linkedin.com/company/yodynix/'),
  ];
}

/// The Meet Our Team roster, in display order (first on the left / top).
/// Photos are the members' own, used unaltered and cropped by layout only.
class TeamConfig {
  TeamConfig._();

  // TODO(yodynix): replace each developer `introduction` with the member's
  // approved wording and set `introductionIsDraft` to false. Their current
  // text uses only the supplied name and role. Leadership text is approved.

  /// Row 1 — founder on the left, partner on the right.
  static const List<TeamMember> leadership = [
    TeamMember(
      name: 'Yogeshwari Abhijit Bhapkar',
      designation: 'Founder & Director',
      introduction:
          'Yogeshwari Abhijit Bhapkar is the Founder & Director of YODYNIX, bringing '
          'around 8 years of industry experience, leadership and a technology-driven vision to '
          'the company. Her professional journey across established organizations has shaped '
          'her approach to building practical digital solutions, understanding business needs '
          'and creating meaningful technology experiences. She leads YODYNIX with a focus on '
          'innovation, quality and long-term growth.',
      photoPath: 'assets/images/team/founder.png',
      // She sits right of centre in a near-square office photo.
      photoAlignment: Alignment(0.9, 0),
    ),
    TeamMember(
      name: 'Abhijit Gajanan Bhapkar',
      designation: 'Partner',
      introduction:
          'Abhijit Gajanan Bhapkar is a Partner at YODYNIX, bringing around 12 years '
          'of professional industry experience, business perspective and strategic insight. His '
          'professional journey across established organizations has helped him develop a '
          'practical understanding of business needs, industry challenges and client '
          'relationships. He contributes to YODYNIX through experience-driven thinking, '
          'strategic guidance and a long-term approach to sustainable growth.',
      photoPath: 'assets/images/team/partner.png',
      photoAlignment: Alignment(0.65, 0),
    ),
  ];

  /// Row 2 — Akash first, then Yogiraj and Ankita.
  static const List<TeamMember> development = [
    TeamMember(
      name: 'Akash Balasaheb Shewale',
      designation: 'Senior Software Developer',
      introduction: 'Akash Balasaheb Shewale is a Senior Software Developer at YODYNIX.',
      introductionIsDraft: true,
      photoPath: 'assets/images/team/akash.jpeg',
      photoAlignment: Alignment(-0.1, 0),
    ),
    TeamMember(
      name: 'Yogiraj Ashok Khalate',
      designation: 'Full Stack Developer',
      introduction: 'Yogiraj Ashok Khalate is a Full Stack Developer at YODYNIX.',
      introductionIsDraft: true,
      photoPath: 'assets/images/team/yogiraj.jpeg',
      // Full-length photo: zoom the crop in on the head and shoulders.
      photoAlignment: Alignment(0, -0.85),
      photoZoom: 1.7,
    ),
    TeamMember(
      name: 'Ankita Raju Mortale',
      designation: 'Full Stack Developer',
      introduction: 'Ankita Raju Mortale is a Full Stack Developer at YODYNIX.',
      introductionIsDraft: true,
      photoPath: 'assets/images/team/ankita.jpeg',
      photoAlignment: Alignment(0, -0.6),
    ),
  ];
}

/// Figures shown in the hero statistics bar.
class HeroStatsConfig {
  HeroStatsConfig._();

  // Confirmed by YODYNIX as genuine business figures (November 2026). Keep
  // them current; never publish a value that has not been verified.
  static const bool verified = true;

  /// (value, suffix, label)
  static const List<(int, String, String)> stats = [
    (23, '+', 'Websites Developed'),
    (40, '+', 'Mobile Apps Developed'),
    (65, '+', 'Projects Completed'),
    (35, '+', 'Happy Clients'),
    (12, '+', 'Technology Solutions'),
  ];
}
