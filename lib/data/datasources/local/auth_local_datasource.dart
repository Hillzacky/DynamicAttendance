import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
  Future<bool> isLoggedIn();
  Future<void> saveDeviceId(String deviceId);
  Future<String?> getDeviceId();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      ),
      _storage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      ),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(
      key: AppConstants.deviceIdKey,
      value: deviceId,
    );
  }

  @override
  Future<String?> getDeviceId() async {
    return _storage.read(key: AppConstants.deviceIdKey);
  }
}