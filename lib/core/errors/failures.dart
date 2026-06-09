import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Tidak ada koneksi internet',
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode = 401,
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
    super.statusCode = 422,
  });

  @override
  List<Object?> get props => [message, statusCode, errors];
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Data tidak ditemukan',
    super.statusCode = 404,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Gagal mengambil data dari cache',
    super.statusCode,
  });
}

class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'Gagal mendapatkan lokasi',
    super.statusCode,
  });
}

class CameraFailure extends Failure {
  const CameraFailure({
    super.message = 'Gagal mengakses kamera',
    super.statusCode,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Izin tidak diberikan',
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Terjadi kesalahan yang tidak diketahui',
    super.statusCode,
  });
}