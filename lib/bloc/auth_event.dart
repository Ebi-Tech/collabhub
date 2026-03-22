import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Check persisted auth on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Google sign-in.
class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

/// Email/password sign-in.
class AuthEmailLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

/// Email/password registration.
class AuthEmailRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthEmailRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

/// Update user profile info.
class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String role;
  final String bio;
  final List<String> skills;
  const AuthProfileUpdateRequested({
    required this.name,
    required this.role,
    required this.bio,
    required this.skills,
  });
  @override
  List<Object?> get props => [name, role, bio, skills];
}

/// Sign out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
