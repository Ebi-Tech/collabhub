import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/models/user_model.dart';
import 'package:collabhub/widgets/project_card.dart';

// ── Mock blocs ────────────────────────────────────────────────────────────────

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// ── Fake event/state stubs (required by mocktail for fallback values) ─────────

class _FakeHomeEvent extends Fake implements HomeEvent {}
class _FakeHomeState extends Fake implements HomeState {}
class _FakeAuthEvent extends Fake implements AuthEvent {}
class _FakeAuthState extends Fake implements AuthState {}

// ── Shared test fixtures ──────────────────────────────────────────────────────

const _currentUser = UserModel(
  id: 'user-1',
  name: 'Test User',
  email: 'test@uni.edu',
);

final _openProject = ProjectModel(
  id: 'proj-1',
  title: 'CollabHub Test Project',
  description: 'A project for widget testing.',
  skills: const ['Flutter', 'Dart'],
  contactEmail: 'hello@uni.edu',
  status: ProjectStatus.open,
  upvotes: 5,
  downvotes: 2,
  authorId: 'author-99',
  authorName: 'Jane Doe',
  authorRole: 'CS Student',
  createdAt: DateTime(2026, 1, 15),
);

final _upvotedProject = _openProject.copyWith(userUpvoted: true);
final _downvotedProject = _openProject.copyWith(userDownvoted: true);

/// Pumps [ProjectCard] inside a full BLoC provider tree.
Future<void> _pumpCard(
  WidgetTester tester, {
  required MockHomeBloc homeBloc,
  required MockAuthBloc authBloc,
  ProjectModel? project,
  bool isOwner = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: homeBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: ProjectCard(
            project: project ?? _openProject,
            isOwner: isOwner,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeHomeEvent());
    registerFallbackValue(_FakeHomeState());
    registerFallbackValue(_FakeAuthEvent());
    registerFallbackValue(_FakeAuthState());
  });

  late MockHomeBloc homeBloc;
  late MockAuthBloc authBloc;

  setUp(() {
    homeBloc = MockHomeBloc();
    authBloc = MockAuthBloc();

    // Default states
    when(() => homeBloc.state).thenReturn(
      const HomeLoaded(allProjects: [], displayedProjects: []),
    );
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_currentUser));
  });

  // ── Rendering ─────────────────────────────────────────────────────────────

  group('ProjectCard — rendering', () {
    testWidgets('displays project title', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('CollabHub Test Project'), findsOneWidget);
    });

    testWidgets('displays project description', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('A project for widget testing.'), findsOneWidget);
    });

    testWidgets('displays author name', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('displays skill badges', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('displays contact email', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('hello@uni.edu'), findsOneWidget);
    });

    testWidgets('shows Open badge for open project', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('shows Closed badge for closed project', (tester) async {
      final closed = _openProject.copyWith(status: ProjectStatus.closed);
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc, project: closed);
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('shows upvote count', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows downvote count', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('hides owner menu when isOwner is false', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc, isOwner: false);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('shows owner menu when isOwner is true', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc, isOwner: true);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows filled upvote icon when userUpvoted is true', (tester) async {
      await _pumpCard(
        tester, homeBloc: homeBloc, authBloc: authBloc, project: _upvotedProject,
      );
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('shows outlined upvote icon when not upvoted', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);
      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
    });

    testWidgets('shows filled downvote icon when userDownvoted is true', (tester) async {
      await _pumpCard(
        tester, homeBloc: homeBloc, authBloc: authBloc, project: _downvotedProject,
      );
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
    });
  });

  // ── Upvote dispatch ──────────────────────────────────────────────────────────

  group('ProjectCard — upvote dispatches HomeUpvoteProject', () {
    testWidgets('tapping upvote adds HomeUpvoteProject to HomeBloc', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);

      await tester.tap(find.byIcon(Icons.thumb_up_outlined));
      await tester.pump();

      verify(
        () => homeBloc.add(
          const HomeUpvoteProject(projectId: 'proj-1', userId: 'user-1'),
        ),
      ).called(1);
    });

    testWidgets('tapping downvote adds HomeDownvoteProject to HomeBloc', (tester) async {
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);

      await tester.tap(find.byIcon(Icons.thumb_down_outlined));
      await tester.pump();

      verify(
        () => homeBloc.add(
          const HomeDownvoteProject(projectId: 'proj-1', userId: 'user-1'),
        ),
      ).called(1);
    });

    testWidgets('no event dispatched when user is unauthenticated', (tester) async {
      when(() => authBloc.state).thenReturn(const AuthUnauthenticated());
      await _pumpCard(tester, homeBloc: homeBloc, authBloc: authBloc);

      await tester.tap(find.byIcon(Icons.thumb_up_outlined));
      await tester.pump();

      verifyNever(() => homeBloc.add(any()));
    });
  });
}
