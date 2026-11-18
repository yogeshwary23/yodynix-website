/// Asset locations. Section images are referenced by *base path* (no
/// extension): drop a `.webp`, `.jpg`, `.jpeg` or `.png` with that name into
/// the folder and it replaces the built-in illustrated placeholder
/// automatically. See `assets/images/IMAGE_GUIDE.md`.
class AssetPaths {
  AssetPaths._();

  /// Recoloured variants of the mark (made by `tool/recolor_logo`); the
  /// original `yodynix_logo.png` is kept unchanged. Deep charcoal + champagne
  /// gold for white and light surfaces; platinum + gold for charcoal bands.
  static const String logo = 'assets/images/brand/yodynix_logo_charcoal.png';
  static const String logoOnDark = 'assets/images/brand/yodynix_logo_gold.png';
  static const String founderPhoto = 'assets/images/team/founder_office.jpg';

  static const String hero = 'assets/images/hero/hero_visual';
  static const String about = 'assets/images/about/about_visual';
  static const String internship = 'assets/images/internship/internship_banner';

  static String service(String id) => 'assets/images/services/$id';

  /// Still renders of the 3D scenes (see `Mobile3DFallback`).
  static String render(String scene) => 'assets/images/renders/$scene';

  /// Sample-project visuals on the service pages.
  static String serviceProject(String id) => 'assets/images/service_projects/$id';

  /// Core pillar card photographs.
  static String pillar(String id) => 'assets/images/pillars/$id';

  /// Pillar detail page photographs, one folder per page.
  static String business(String id) => 'assets/images/business/$id';
  static String technology(String id) => 'assets/images/technology/$id';
  static String internshipCareers(String id) => 'assets/images/internship_careers/$id';
}
