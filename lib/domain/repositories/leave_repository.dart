import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/leave_model.dart';

abstract class LeaveRepository {
  Future<Either<Failure, LeaveModel>> createLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? notes,
    File? document,
  });

  Future<Either<Failure, List<LeaveModel>>> getLeaves({
    int page = 1,
    int limit = 10,
    String? userId,
    String? status,
    String? leaveTypeId,
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, LeaveModel>> getLeaveById(String id);

  Future<Either<Failure, LeaveModel>> updateLeaveStatus({
    required String id,
    required String status,
    String? rejectionReason,
  });

  Future<Either<Failure, void>> cancelLeave(String id);

  Future<Either<Failure, Map<String, dynamic>>> getLeaveCalendar({
    required int month,
    required int year,
    String? userId,
  });

  Future<Either<Failure, List<LeaveTypeModel>>> getLeaveTypes();
  Future<Either<Failure, void>> deleteLeave(String id);
}