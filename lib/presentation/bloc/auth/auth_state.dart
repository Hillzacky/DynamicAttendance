import 'package:equatable/equatable.dart';
import 'package:attendance_app/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoginSuccess extends AuthState {
  final UserModel user;

  const AuthLoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthLoginFailure extends AuthState {
  final String message;
  final Map<String, List<String>>? errors;

  const AuthLoginFailure({
    required this.message,
    this.errors,
  });

  @override
  List<Object?> get props => [message, errors];
}

class AuthLogoutSuccess extends AuthState {
  const AuthLogoutSuccess();
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  const AuthForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordFailure extends AuthState {
  final String message;

  const AuthForgotPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthResetPasswordSuccess extends AuthState {
  const AuthResetPasswordSuccess();
}

class AuthResetPasswordFailure extends AuthState {
  final String message;

  const AuthResetPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}