import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_event.dart';
import 'package:collabhub/bloc/auth_state.dart';
import 'package:collabhub/services/auth_service.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthEmailLoginRequested>(_onEmailLogin);
    on<AuthEmailRegisterRequested>(_onEmailRegister);
    on<AuthProfileUpdateRequested>(_onProfileUpdate);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleLogin(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailLogin(
    AuthEmailLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signInWithEmail(
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onEmailRegister(
    AuthEmailRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.registerWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onProfileUpdate(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;
    final currentUser = (state as AuthAuthenticated).user;
    try {
      final updated = await _authService.updateProfile(
        user: currentUser,
        name: event.name,
        role: event.role,
        bio: event.bio,
        skills: event.skills,
        avatarLocalPath: event.avatarLocalPath,
      );
      emit(AuthAuthenticated(updated));
    } catch (e) {
      emit(AuthError(e.toString()));
      // Restore previous state so the UI doesn't break
      emit(AuthAuthenticated(currentUser));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }
}
