import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// fired on startup to see if someone is already logged in
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthEmailLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

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

class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String role;
  final String bio;
  final List<String> skills;
  final String? avatarLocalPath; // null means user didn't pick a new photo
  const AuthProfileUpdateRequested({
    required this.name,
    required this.role,
    required this.bio,
    required this.skills,
    this.avatarLocalPath,
  });
  @override
  List<Object?> get props => [name, role, bio, skills, avatarLocalPath];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// clears the "please log in" prompt after the snackbar has been shown
class AuthPostRegistrationAcknowledged extends AuthEvent {
  const AuthPostRegistrationAcknowledged();
}
