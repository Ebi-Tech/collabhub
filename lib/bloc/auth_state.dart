import 'package:equatable/equatable.dart';
import 'package:collabhub/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial / splash state.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A request is in-flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is signed in.
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

/// No signed-in user.
class AuthUnauthenticated extends AuthState {
  /// When true, show a one-time hint on [LoginScreen] after email registration.
  final bool promptLoginAfterRegistration;
  const AuthUnauthenticated({this.promptLoginAfterRegistration = false});
  @override
  List<Object?> get props => [promptLoginAfterRegistration];
}

/// An error occurred (login failure, etc.).
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
