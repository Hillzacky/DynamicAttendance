import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/attendance_model.dart';

abstract class AttendanceRepository {
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
  });

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
  });

  Future<Either<Failure, TodayAttendanceModel>> getTodayAttendance();

  Future<Either<Failure, Map<String, dynamic>>> getAttendanceCalendar({
    required int month,
    required int year,
    String? userId,
    String? attendanceMode,
  });

  Future<Either<Failure, Map<String, dynamic>>> getAttendanceStatistics({
    required int month,
    required int year,
    String? userId,
  });

  Future<Either<Failure, List<AttendanceModel>>> getAttendances({
    int page = 1,
    int limit = 10,
    String? userId,
    String? type,
    String? status,
    String? attendanceMode,
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, AttendanceModel>> getAttendanceById(String id);
}