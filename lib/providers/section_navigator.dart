import 'package:flutter/material.dart';

import '../models/site_section.dart';

/// Owns the homepage scroll position: smooth-scrolls to sections, tracks the
/// active navigation item and carries contact-form prefill requests from CTAs.
class SectionNavigator extends ChangeNotifier {
  SectionNavigator() {
    scrollController.addListener(_onScroll);
  }

  final ScrollController scrollController = ScrollController();
  final Map<SiteSection, GlobalKey> _keys = {
    for (final section in SiteSection.values) section: GlobalKey(debugLabel: section.name),
  };

  /// Service name requested by a CTA, consumed by the contact form.
  final ValueNotifier<String?> contactPrefill = ValueNotifier<String?>(null);

  SiteSection _active = SiteSection.home;
  bool _isScrolled = false;
  bool _isAnimating = false;

  SiteSection get active => _active;
  bool get isScrolled => _isScrolled;

  GlobalKey keyFor(SiteSection section) => _keys[section]!;

  Future<void> scrollTo(SiteSection section) async {
    final context = _keys[section]!.currentContext;
    if (context == null) return;
    _setActive(section.inNavigation ? section : _navOwnerOf(section));
    _isAnimating = true;
    try {
      await Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 750), curve: Curves.easeInOutCubic);
    } finally {
      _isAnimating = false;
      _onScroll();
    }
  }

  /// Jumps to [section] once the homepage has laid out — used for deep links
  /// such as `/#/internship`.
  void revealOnLaunch(SiteSection section) {
    void attempt([int tries = 0]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _keys[section]!.currentContext;
        if (context == null) {
          if (tries < 10) attempt(tries + 1);
          return;
        }
        _setActive(section.inNavigation ? section : _navOwnerOf(section));
        Scrollable.ensureVisible(context);
        // Re-align once fonts and late layout above the section have settled.
        Future<void>.delayed(const Duration(milliseconds: 700), () {
          final settled = _keys[section]!.currentContext;
          if (settled != null && settled.mounted) {
            Scrollable.ensureVisible(settled, duration: const Duration(milliseconds: 300));
          }
        });
      });
    }

    attempt();
  }

  /// Scrolls to the enquiry form, optionally pre-selecting a service.
  Future<void> startEnquiry({String? service}) {
    if (service != null) contactPrefill.value = service;
    return scrollTo(SiteSection.contact);
  }

  SiteSection _navOwnerOf(SiteSection section) {
    final sections = SiteSection.values;
    for (var i = section.index; i >= 0; i--) {
      if (sections[i].inNavigation) return sections[i];
    }
    return SiteSection.home;
  }

  /// The homepage's scroll position. `ScrollController.position` throws if
  /// the controller is ever attached to more than one scroll view (e.g.
  /// briefly during a route change), so the most recent one is used.
  ScrollPosition get _position => scrollController.positions.last;

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final scrolled = _position.pixels > 8;
    var changed = scrolled != _isScrolled;
    _isScrolled = scrolled;

    if (!_isAnimating) {
      final next = _computeActive();
      if (next != _active) {
        _active = next;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  SiteSection _computeActive() {
    final position = _position;
    if (position.pixels >= position.maxScrollExtent - 4) return SiteSection.contact;

    final viewport = position.context.storageContext.findRenderObject();
    if (viewport is! RenderBox) return _active;
    final threshold = position.viewportDimension * 0.3;

    var current = SiteSection.home;
    for (final section in SiteSection.navigation) {
      final box = _keys[section]!.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      if (top <= threshold) current = section;
    }
    return current;
  }

  void _setActive(SiteSection section) {
    if (_active == section) return;
    _active = section;
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    contactPrefill.dispose();
    super.dispose();
  }
}

class SectionNavigatorScope extends InheritedNotifier<SectionNavigator> {
  const SectionNavigatorScope({super.key, required SectionNavigator navigator, required super.child})
    : super(notifier: navigator);

  /// Subscribes the caller to navigation changes (active item, scrolled state).
  static SectionNavigator of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SectionNavigatorScope>();
    assert(scope != null, 'SectionNavigatorScope not found');
    return scope!.notifier!;
  }

  /// Reads the navigator without subscribing — use in callbacks.
  static SectionNavigator read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<SectionNavigatorScope>();
    assert(element != null, 'SectionNavigatorScope not found');
    return (element!.widget as SectionNavigatorScope).notifier!;
  }
}
