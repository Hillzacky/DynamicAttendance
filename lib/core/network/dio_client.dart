import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendance_app/core/constants/api_constants.dart';
import 'package:attendance_app/core/constants/app_constants.dart';

class DioClient {
  static Dio? _dio;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  static void reset() {
    _dio = null;
  }
}

// =============================================
// Auth Interceptor
// =============================================
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(
      key: AppConstants.accessTokenKey,
    );

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _storage.read(
          key: AppConstants.refreshTokenKey,
        );

        if (refreshToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Refresh token
        final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
        final response = await dio.post(
          ApiConstants.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newToken = response.data['data']['access_token'];
          final newRefreshToken = response.data['data']['refresh_token'];

          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: newToken,
          );
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await DioClient.instance.fetch(
            err.requestOptions,
          );
          _isRefreshing = false;
          handler.resolve(retryResponse);
          return;
        }
      } catch (e) {
        // Clear tokens on refresh failure
        await _storage.delete(key: AppConstants.accessTokenKey);
        await _storage.delete(key: AppConstants.refreshTokenKey);
        await _storage.delete(key: AppConstants.userKey);
      }

      _isRefreshing = false;
    }

    handler.next(err);
  }
}
// =============================================
// Logging Interceptor
// =============================================
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('🚀 REQUEST[${options.method}] => ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '�� RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}'
    );
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => '
      '${err.requestOptions.uri}: ${err.message}'
    );
    handler.next(err);
  }
}

// =============================================
// Error Interceptor
// =============================================
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(
          'Koneksi timeout. Periksa koneksi internet Anda',
        );

      case DioExceptionType.connectionError:
        throw NetworkException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda',
        );

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = err.response?.data?['message'] ?? 'Terjadi kesalahan';
        final errors = err.response?.data?['errors'];

        switch (statusCode) {
          case 400:
            throw BadRequestException(message, errors: errors);
          case 401:
            throw UnauthorizedException(message);
          case 403:
            throw ForbiddenException(message);
          case 404:
            throw NotFoundException(message);
          case 409:
            throw ConflictException(message);
          case 422:
            throw ValidationException(message, errors: errors);
          case 429:
            throw TooManyRequestsException(message);
          default:
            throw ServerException(message, statusCode: statusCode);
        }

      default:
        handler.next(err);
    }
  }
}

// =============================================
// Custom Exceptions
// =============================================
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  const AppException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.errors});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message) : super(statusCode: 403);
}
class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException(super.message) : super(statusCode: 409);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.errors})
      : super(statusCode: 422);
}

class TooManyRequestsException extends AppException {
  const TooManyRequestsException(super.message) : super(statusCode: 429);
}