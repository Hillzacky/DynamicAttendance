import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/core/network/dio_client.dart';
import 'package:attendance_app/data/datasources/local/auth_local_datasource.dart';
import 'package:attendance_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:attendance_app/data/models/user_model.dart';
import 'package:attendance_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, UserModel>> login({
    required String username,
    required String password,
    String? deviceId,
    String? deviceName,
    String? devicePlatform,
  }) async {
    try {
      final data = await _remote.login(
        username: username,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
        devicePlatform: devicePlatform,
      );

      final user = UserModel.fromJson(data['user']);
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      // Save to local storage
      await _local.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await _local.saveUser(user);

      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors != null
            ? Map<String, List<String>>.from(e.errors)
            : null,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remote.logout();
      await _local.clearAll();
      DioClient.reset();
      return const Right(null);
    } catch (e) {
      // Clear local even if remote fails
      await _local.clearAll();
      DioClient.reset();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyToken() async {
    try {
      final user = await _remote.verifyToken();
      await _local.saveUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      // Try to get cached user
      final cachedUser = await _local.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remote.forgotPassword(email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remote.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCachedUser() async {
    try {
      final user = await _local.getUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final loggedIn = await _local.isLoggedIn();
      return Right(loggedIn);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeviceId(String deviceId) async {
    try {
      await _local.saveDeviceId(deviceId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getDeviceId() async {
    try {
      final deviceId = await _local.getDeviceId();
      return Right(deviceId);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}