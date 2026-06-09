import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remote;

  AttendanceRepositoryImpl({
    required AttendanceRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, AttendanceModel>> createAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required double employeeLatitude,
    required double employeeLongitude,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  }) async {
    try {
      final attendance = await _remote.createAttendance(
        locationId: locationId,
        shiftId: shiftId,
        type: type,
        employeeLatitude: employeeLatitude,
        employeeLongitude: employeeLongitude,
        photo: photo,
        notes: notes,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      return Right(attendance);
    } on BadRequestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 400,
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors != null
            ? Map<String, List<String>>.from(e.errors)
            : null,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 409,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceModel>> createManualAttendance({
    required String locationId,
    required String shiftId,
    required String type,
    required String manualDate,
    required String manualTime,
    required String manualReason,
    File? photo,
    String? notes,
    String? deviceId,
    String? deviceName,
  }) async {
    try {
      final attendance = await _remote.createManualAttendance(
        locationId: locationId,
        shiftId: shiftId,
        type: type,
        manualDate: manualDate,
        manualTime: manualTime,
        manualReason: manualReason,
        photo: photo,
        notes: notes,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      return Right(attendance);
    } on BadRequestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 400,
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(
        message: e.message,
        errors: e.errors != null
            ? Map<String, List<String>>.from(e.errors)
            : null,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 409,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TodayAttendanceModel>> getTodayAttendance() async {
    try {
      final data = await _remote.getTodayAttendance();
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceCalendar({
    required int month,
    required int year,
    String? userId,
    String? attendanceMode,
  }) async {
    try {
      final data = await _remote.getAttendanceCalendar(
        month: month,
        year: year,
        userId: userId,
        attendanceMode: attendanceMode,
      );
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceStatistics({
    required int month,
    required int year,
    String? userId,
  }) async {
    try {
      final data = await _remote.getAttendanceStatistics(
        month: month,
        year: year,
        userId: userId,
      );
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceModel>>> getAttendances({
    int page = 1,
    int limit = 10,
    String? userId,
    String? type,
    String? status,
    String? attendanceMode,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final data = await _remote.getAttendances(
        page: page,
        limit: limit,
        userId: userId,
        type: type,
        status: status,
        attendanceMode: attendanceMode,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceModel>> getAttendanceById(
    String id,
  ) async {
    try {
      final data = await _remote.getAttendanceById(id);
      return Right(data);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}