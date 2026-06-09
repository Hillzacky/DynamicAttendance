import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/datasources/remote/leave_remote_datasource.dart';
import 'package:attendance_app/data/models/leave_model.dart';
import 'package:attendance_app/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource _remote;

  LeaveRepositoryImpl({
    required LeaveRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, LeaveModel>> createLeave({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? notes,
    File? document,
  }) async {
    try {
      final leave = await _remote.createLeave(
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
        document: document,
      );
      return Right(leave);
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
    } on ConflictException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 409,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaveModel>>> getLeaves({
    int page = 1,
    int limit = 10,
    String? userId,
    String? status,
    String? leaveTypeId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final leaves = await _remote.getLeaves(
        page: page,
        limit: limit,
        userId: userId,
        status: status,
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(leaves);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaveModel>> getLeaveById(String id) async {
    try {
      final leave = await _remote.getLeaveById(id);
      return Right(leave);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaveModel>> updateLeaveStatus({
    required String id,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final leave = await _remote.updateLeaveStatus(
        id: id,
        status: status,
        rejectionReason: rejectionReason,
      );
      return Right(leave);
    } on BadRequestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 400,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelLeave(String id) async {
    try {
      await _remote.cancelLeave(id);
      return const Right(null);
    } on BadRequestException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: 400,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveCalendar({
    required int month,
    required int year,
    String? userId,
  }) async {
    try {
      final data = await _remote.getLeaveCalendar(
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
  Future<Either<Failure, List<LeaveTypeModel>>> getLeaveTypes() async {
    try {
      final leaveTypes = await _remote.getLeaveTypes();
      return Right(leaveTypes);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLeave(String id) async {
    try {
      await _remote.deleteLeave(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}