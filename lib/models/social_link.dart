import 'package:flutter/material.dart';

enum SocialPlatform {
  instagram('Instagram'),
  facebook('Facebook'),
  linkedin('LinkedIn'),
  x('X'),
  youtube('YouTube'),
  github('GitHub'),
  website('Website');

  const SocialPlatform(this.label);
  final String label;

  IconData get icon => switch (this) {
    SocialPlatform.instagram => Icons.camera_alt_outlined,
    SocialPlatform.facebook => Icons.facebook_rounded,
    SocialPlatform.linkedin => Icons.work_outline_rounded,
    SocialPlatform.x => Icons.alternate_email_rounded,
    SocialPlatform.youtube => Icons.smart_display_outlined,
    SocialPlatform.github => Icons.code_rounded,
    SocialPlatform.website => Icons.public_rounded,
  };
}

class SocialLink {
  const SocialLink({required this.platform, required this.url, this.handle});

  final SocialPlatform platform;
  final String url;

  /// Profile handle shown beside the platform name, e.g. '@yodynix'.
  final String? handle;
}
