import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/bloc/theme_cubit.dart';
import 'package:collabhub/screens/auth/login_screen.dart';
import 'package:collabhub/screens/main_screen.dart';
import 'package:collabhub/services/auth_service.dart';
import 'package:collabhub/services/firestore_service.dart';
import 'package:collabhub/services/prefs_service.dart';
import 'package:collabhub/utils/constants.dart';

class CollabHubApp extends StatelessWidget {
  const CollabHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => FirestoreService()),
        RepositoryProvider(create: (_) => PrefsService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => ThemeCubit(ctx.read<PrefsService>()),
          ),
          BlocProvider(
            create: (ctx) => AuthBloc(
              authService: ctx.read<AuthService>(),
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider(
            create: (ctx) => HomeBloc(
              firestoreService: ctx.read<FirestoreService>(),
              prefsService: ctx.read<PrefsService>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'CollabHub',
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              home: const _AuthGate(),
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.gray50,
      fontFamily: 'Roboto',
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF1C1C2E),
      ),
      scaffoldBackgroundColor: const Color(0xFF13131A),
      fontFamily: 'Roboto',
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// decides whether to show the login screen or the main app
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<HomeBloc>().add(HomeLoadProjects(state.user.id));
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is AuthAuthenticated) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
