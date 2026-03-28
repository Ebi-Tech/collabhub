import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/widgets/custom_button.dart';
import 'package:collabhub/utils/constants.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton — label rendering', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Submit', onPressed: () {})),
      );
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Add',
          onPressed: () {},
          icon: const Icon(Icons.add),
        )),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppButton — tap behaviour', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Go', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when null', (tester) async {
      // Should not throw.
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'Disabled')),
      );
      await tester.tap(find.byType(AppButton));
      // No assertion needed — just confirming no exception is thrown.
    });

    testWidgets('does not call onPressed when isLoading is true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Loading',
          onPressed: () => tapped = true,
          isLoading: true,
        )),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });
  });

  group('AppButton — loading state', () {
    testWidgets('shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Submit',
          onPressed: () {},
          isLoading: true,
        )),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides label text when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Submit',
          onPressed: () {},
          isLoading: true,
        )),
      );
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('shows label and hides spinner when isLoading is false',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Submit', onPressed: () {})),
      );
      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('AppButton — variants', () {
    testWidgets('primary variant uses primary color background', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Primary',
          onPressed: () {},
          variant: AppButtonVariant.primary,
        )),
      );
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(AppButton), matching: find.byType(Material)).first,
      );
      expect(material.color, AppColors.primary);
    });

    testWidgets('outline variant uses transparent background', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Outline',
          onPressed: () {},
          variant: AppButtonVariant.outline,
        )),
      );
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(AppButton), matching: find.byType(Material)).first,
      );
      expect(material.color, Colors.transparent);
    });
  });

  group('AppButton — fullWidth', () {
    testWidgets('fullWidth wraps button in SizedBox with infinite width',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Wide', onPressed: () {}, fullWidth: true)),
      );
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(of: find.byType(AppButton), matching: find.byType(SizedBox)).first,
      );
      expect(sizedBox.width, double.infinity);
    });
  });

  group('AppButton — size variants', () {
    testWidgets('small size renders without error', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Small',
          onPressed: () {},
          size: AppButtonSize.small,
        )),
      );
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('normal size renders without error', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Normal',
          onPressed: () {},
          size: AppButtonSize.normal,
        )),
      );
      expect(find.text('Normal'), findsOneWidget);
    });
  });
}
