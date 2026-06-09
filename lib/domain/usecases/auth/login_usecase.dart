import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/user_model.dart';
import 'package:attendance_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, UserModel>> call(LoginParams params) {
    return _repository.login(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
      deviceName: params.deviceName,
      devicePlatform: params.devicePlatform,
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;
  final String? deviceId;
  final String? deviceName;
  final String? devicePlatform;

  const LoginParams({
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