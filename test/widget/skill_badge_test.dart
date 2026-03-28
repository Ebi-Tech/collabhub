import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/widgets/skill_badge.dart';
import 'package:collabhub/utils/constants.dart';

/// Wraps [child] in a [MaterialApp] with the given [brightness].
Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SkillBadge — rendering', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(_wrap(const SkillBadge(label: 'Flutter')));
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('shows close icon when onRemove is provided', (tester) async {
      await tester.pumpWidget(
        _wrap(SkillBadge(label: 'Dart', onRemove: () {})),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close icon when onRemove is null', (tester) async {
      await tester.pumpWidget(_wrap(const SkillBadge(label: 'Python')));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('tapping close icon calls onRemove', (tester) async {
      bool removed = false;
      await tester.pumpWidget(
        _wrap(SkillBadge(label: 'React', onRemove: () => removed = true)),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(removed, isTrue);
    });
  });

  group('SkillBadge — light theme', () {
    testWidgets('badge background uses secondary colour in light mode',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const SkillBadge(label: 'Firebase'), brightness: Brightness.light),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SkillBadge),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.secondary);
    });

    testWidgets('label text is rendered in light mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const SkillBadge(label: 'SwiftUI'), brightness: Brightness.light),
      );
      expect(find.text('SwiftUI'), findsOneWidget);
    });
  });

  group('SkillBadge — dark theme', () {
    testWidgets('badge background uses dark badgeBg colour in dark mode',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const SkillBadge(label: 'Firebase'), brightness: Brightness.dark),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SkillBadge),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      // Dark mode badge bg is 0xFF2A2A3E
      expect(decoration.color, const Color(0xFF2A2A3E));
    });

    testWidgets('label text is rendered in dark mode', (tester) async {
      await tester.pumpWidget(
        _wrap(const SkillBadge(label: 'Kotlin'), brightness: Brightness.dark),
      );
      expect(find.text('Kotlin'), findsOneWidget);
    });
  });

  group('SkillBadge — multiple badges', () {
    testWidgets('multiple badges are all visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Wrap(
            children: [
              SkillBadge(label: 'Flutter'),
              SkillBadge(label: 'Dart'),
              SkillBadge(label: 'Firebase'),
            ],
          ),
        ),
      );
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
    });
  });
}
