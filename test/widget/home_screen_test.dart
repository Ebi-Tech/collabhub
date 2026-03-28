import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/models/user_model.dart';
import 'package:collabhub/screens/home/home_screen.dart';

// ── Mock blocs ────────────────────────────────────────────────────────────────

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// ── Fake stubs ────────────────────────────────────────────────────────────────

class _FakeHomeEvent extends Fake implements HomeEvent {}
class _FakeHomeState extends Fake implements HomeState {}
class _FakeAuthEvent extends Fake implements AuthEvent {}
class _FakeAuthState extends Fake implements AuthState {}

// ── Test fixtures ─────────────────────────────────────────────────────────────

const _viewer = UserModel(id: 'viewer-1', name: 'Viewer', email: 'v@uni.edu');

ProjectModel _makeProject(String id, String title) => ProjectModel(
      id: id,
      title: title,
      description: 'Description for $title.',
      skills: const ['Flutter'],
      contactEmail: 'contact@uni.edu',
      status: ProjectStatus.open,
      upvotes: 3,
      downvotes: 0,
      authorId: 'other-user',
      authorName: 'Author Name',
      authorRole: 'Engineer',
      createdAt: DateTime(2026, 1, 1),
    );

final _project1 = _makeProject('p-1', 'Smart Campus App');
final _project2 = _makeProject('p-2', 'AI Tutor Platform');

HomeLoaded _loadedWith(List<ProjectModel> projects) => HomeLoaded(
      allProjects: projects,
      displayedProjects: projects,
    );

/// Pumps [HomeScreen] with mocked blocs inside a full [MaterialApp] + [Scaffold].
Future<void> _pumpHomeScreen(
  WidgetTester tester, {
  required MockHomeBloc homeBloc,
  required MockAuthBloc authBloc,
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
          child: const HomeScreen(),
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
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_viewer));
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  group('HomeScreen — loading state', () {
    testWidgets('shows CircularProgressIndicator while HomeLoading', (tester) async {
      when(() => homeBloc.state).thenReturn(const HomeLoading());
      whenListen(homeBloc, Stream.fromIterable([const HomeLoading()]),
          initialState: const HomeLoading());

      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Error state ───────────────────────────────────────────────────────────

  group('HomeScreen — error state', () {
    testWidgets('shows error message on HomeError', (tester) async {
      const err = HomeError('Something went wrong');
      when(() => homeBloc.state).thenReturn(err);
      whenListen(homeBloc, Stream.fromIterable([err]), initialState: err);

      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });

  // ── Loaded state — two projects ───────────────────────────────────────────

  group('HomeScreen — loaded with two projects', () {
    late HomeLoaded twoProjects;

    setUp(() {
      twoProjects = _loadedWith([_project1, _project2]);
      when(() => homeBloc.state).thenReturn(twoProjects);
      whenListen(homeBloc, Stream.fromIterable([twoProjects]),
          initialState: twoProjects);
    });

    testWidgets('smoke test — screen renders without error', (tester) async {
      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      // No exception = pass.
    });

    testWidgets('shows title of first project', (tester) async {
      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      expect(find.text('Smart Campus App'), findsOneWidget);
    });

    testWidgets('shows title of second project', (tester) async {
      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      expect(find.text('AI Tutor Platform'), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      expect(
        find.widgetWithText(TextField, 'Search projects, skills, or people...'),
        findsOneWidget,
      );
    });

    testWidgets('renders Filter button', (tester) async {
      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      expect(find.text('Filter'), findsOneWidget);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('HomeScreen — empty project list', () {
    testWidgets('shows empty-state prompt when no projects', (tester) async {
      final empty = _loadedWith([]);
      when(() => homeBloc.state).thenReturn(empty);
      whenListen(homeBloc, Stream.fromIterable([empty]), initialState: empty);

      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();

      expect(find.text('No projects yet. Be the first to post!'), findsOneWidget);
    });
  });

  // ── Search dispatches event ───────────────────────────────────────────────

  group('HomeScreen — search bar interaction', () {
    testWidgets('typing in search bar dispatches HomeSearchChanged', (tester) async {
      final loaded = _loadedWith([_project1]);
      when(() => homeBloc.state).thenReturn(loaded);
      whenListen(homeBloc, Stream.fromIterable([loaded]), initialState: loaded);

      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      verify(() => homeBloc.add(const HomeSearchChanged('flutter'))).called(1);
    });
  });

  // ── Transient error snackbar ──────────────────────────────────────────────

  group('HomeScreen — transient error snackbar', () {
    testWidgets('shows snackbar when transientError is set', (tester) async {
      const withError = HomeLoaded(
        allProjects: [],
        displayedProjects: [],
        transientError: 'Vote failed',
      );
      final initial = _loadedWith([]);
      when(() => homeBloc.state).thenReturn(withError);
      whenListen(
        homeBloc,
        Stream.fromIterable([initial, withError]),
        initialState: initial,
      );

      await _pumpHomeScreen(tester, homeBloc: homeBloc, authBloc: authBloc);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vote failed'), findsOneWidget);
    });
  });
}
