import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  final bool obscurePassword;
  final bool showValidationError;

  const AuthState({
    this.obscurePassword = true,
    this.showValidationError = false,
  });

  @override
  List<Object?> get props => [obscurePassword, showValidationError];
}

class AuthInitial extends AuthState {
  const AuthInitial({
    super.obscurePassword,
    super.showValidationError,
  });
}

class AuthLoading extends AuthState {
  const AuthLoading({
    super.obscurePassword = true,
    super.showValidationError = false,
  });
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user, obscurePassword, showValidationError];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({
    super.obscurePassword,
    super.showValidationError,
  });
}

class AuthError extends AuthState {
  final String message;

  const AuthError(
    this.message, {
    super.obscurePassword,
    super.showValidationError,
  });

  @override
  List<Object?> get props => [message, obscurePassword, showValidationError];
}