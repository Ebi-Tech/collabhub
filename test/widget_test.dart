import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collabhub/app.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/models/user_model.dart';
import 'package:collabhub/widgets/skill_badge.dart';

// ── Widget tests ──────────────────────────────────────────────────────────────

void main() {
  group('CollabHubApp widget test', () {
    testWidgets('shows loading spinner on initial state', (tester) async {
      await tester.pumpWidget(const CollabHubApp());
      // On first pump auth is AuthInitial → shows spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SkillBadge widget test', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillBadge(label: 'Flutter'),
          ),
        ),
      );
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('shows remove icon when onRemove is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkillBadge(label: 'React', onRemove: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does not show remove icon when onRemove is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkillBadge(label: 'Python'),
          ),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}

// ── Unit tests ────────────────────────────────────────────────────────────────

// These are declared outside testWidgets so they run as plain unit tests.
void unitTests() {
  group('UserModel', () {
    test('initials from full name', () {
      const user = UserModel(id: '1', name: 'Alex Martinez', email: 'a@b.com');
      expect(user.initials, 'AM');
    });

    test('initials from single name', () {
      const user = UserModel(id: '2', name: 'Alex', email: 'a@b.com');
      expect(user.initials, 'A');
    });

    test('copyWith updates fields', () {
      const user =
          UserModel(id: '1', name: 'Alex', email: 'a@b.com', role: 'CS');
      final updated = user.copyWith(name: 'Bob');
      expect(updated.name, 'Bob');
      expect(updated.role, 'CS'); // unchanged
    });
  });

  group('ProjectModel', () {
    final baseProject = ProjectModel(
      id: 'p1',
      title: 'Test Project',
      description: 'A description',
      skills: const ['Flutter'],
      contactEmail: 'test@uni.edu',
      status: ProjectStatus.open,
      upvotes: 5,
      downvotes: 1,
      authorId: 'u1',
      authorName: 'Jane Doe',
      authorRole: 'CS',
      createdAt: DateTime(2026, 1, 1),
    );

    test('isOpen returns true for open status', () {
      expect(baseProject.isOpen, isTrue);
    });

    test('isOpen returns false for closed status', () {
      final closed = baseProject.copyWith(status: ProjectStatus.closed);
      expect(closed.isOpen, isFalse);
    });

    test('authorInitials from full name', () {
      expect(baseProject.authorInitials, 'JD');
    });

    test('copyWith preserves unchanged fields', () {
      final updated = baseProject.copyWith(upvotes: 10);
      expect(updated.upvotes, 10);
      expect(updated.title, 'Test Project');
    });
  });
}
