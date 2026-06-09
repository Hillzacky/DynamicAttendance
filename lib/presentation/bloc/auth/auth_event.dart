import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;
  final String? deviceId;
  final String? deviceName;
  final String? devicePlatform;

  const AuthLoginEvent({
    required this.username,
    required this.password,
    this.deviceId,
    this.deviceName,
    this.devicePlatform,
  });

  @override
  List<Object?> get props => [
    username, password, deviceId,
    deviceName, devicePlatform,
  ];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthVerifyTokenEvent extends AuthEvent {
  const AuthVerifyTokenEvent();
}

class AuthCheckLoginEvent extends AuthEvent {
  const AuthCheckLoginEvent();
}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const AuthResetPasswordEvent({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}