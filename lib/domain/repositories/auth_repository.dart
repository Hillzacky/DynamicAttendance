import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
    String? deviceId,
    String? deviceName,
    String? devicePlatform,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel>> verifyToken();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
  Future<Either<Failure, UserModel?>> getCachedUser();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, void>> saveDeviceId(String deviceId);
  Future<Either<Failure, String?>> getDeviceId();
}