import 'package:dio/dio.dart';
import 'package:attendance_app/core/constants/api_constants.dart';
import 'package:attendance_app/core/network/dio_client.dart';
import 'package:attendance_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? deviceId,
    String? deviceName,
    String? devicePlatform,
  });
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<UserModel> verifyToken();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? deviceId,
    String? deviceName,
    String? devicePlatform,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
        if (deviceId != null) 'device_id': deviceId,
        if (deviceName != null) 'device_name': deviceName,
        if (devicePlatform != null) 'device_platform': devicePlatform,
      },
    );

    return response.data['data'];
  }
  @override
  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    return response.data['data'];
  }

  @override
  Future<UserModel> verifyToken() async {
    final response = await _dio.get(ApiConstants.verifyToken);
    return UserModel.fromJson(response.data['data']['user']);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }
}