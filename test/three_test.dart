import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yodynix_website/repositories/content/services_content.dart';
import 'package:yodynix_website/shared/three/interactive_3d_object.dart';
import 'package:yodynix_website/shared/three/scene3d.dart';
import 'package:yodynix_website/shared/three/scene_widgets.dart';
import 'package:yodynix_website/shared/three/scroll_animation_controller.dart';

void main() {
  test('every service maps to a scene, and shared scenes use distinct variants', () {
    final seen = <String>{};
    for (final s in ServicesContent.services) {
      final scene = Service3DVisual.sceneFor(s.id);
      final name = renderName(scene, Service3DVisual.variantFor(s.id));
      expect(seen.add(name), isTrue, reason: '${s.id} repeats the visual "$name"');
    }
  });

  testWidgets('Interactive3DObject shows its fallback where WebGL is unavailable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 400,
          height: 300,
          child: Interactive3DObject(
            scene: Scene3D.web,
            semanticLabel: 'A laptop',
            background: Colors.white,
            fallback: Text('fallback'),
          ),
        ),
      ),
    );
    await tester.pump();
    // Unit tests run off the web, where the engine stub reports no WebGL.
    expect(find.text('fallback'), findsOneWidget);
    expect(find.bySemanticsLabel('A laptop'), findsOneWidget);
  });

  testWidgets('ScrollAnimationController reports progress and visibility', (tester) async {
    final placements = <ScrollPlacement>[];
    final controller = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              const SizedBox(height: 1000),
              _Probe(onChanged: placements.add),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    // 600px viewport; the probe starts 400px below the fold.
    expect(placements.last.visible, isFalse);
    expect(placements.last.progress, 0);

    controller.jumpTo(700); // probe top now at 300 in a 600px viewport
    await tester.pump();
    expect(placements.last.visible, isTrue);
    expect(placements.last.progress, closeTo(300 / 800, 0.01));

    controller.jumpTo(2000); // probe has left the top
    await tester.pump();
    expect(placements.last.visible, isFalse);
    expect(placements.last.progress, 1);
  });
}

class _Probe extends StatefulWidget {
  const _Probe({required this.onChanged});

  final ValueChanged<ScrollPlacement> onChanged;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  late final ScrollAnimationController _scroll = ScrollAnimationController(onChanged: widget.onChanged);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scroll.attach(context);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 200);
}
