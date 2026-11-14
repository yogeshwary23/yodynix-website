import 'package:flutter/painting.dart';

/// A person shown on the Meet Our Team page. [photoAlignment] positions the
/// supplied photograph inside its crop — the image itself is never altered.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.designation,
    required this.introduction,
    required this.photoPath,
    this.photoAlignment = Alignment.topCenter,
    this.photoZoom = 1,
    this.introductionIsDraft = false,
  });

  final String name;
  final String designation;
  final String introduction;
  final String photoPath;
  final Alignment photoAlignment;

  /// Extra crop toward [photoAlignment] for full-length photos, so the face
  /// still reads in a small frame. Scales the crop only, never the image.
  final double photoZoom;

  /// True while [introduction] is built only from supplied facts and awaits
  /// the member's approved wording.
  final bool introductionIsDraft;
}
