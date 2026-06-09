import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/leave_model.dart';
import 'package:attendance_app/domain/repositories/leave_repository.dart';

class CreateLeaveUseCase {
  final LeaveRepository _repository;

  CreateLeaveUseCase(this._repository);

  Future<Either<Failure, LeaveModel>> call(CreateLeaveParams params) {
    return _repository.createLeave(
      leaveTypeId: params.leaveTypeId,
      startDate: params.startDate,
      endDate: params.endDate,
      notes: params.notes,
      document: params.document,
    );
  }
}

class CreateLeaveParams extends Equatable {
  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final String? notes;
  final File? document;

  const CreateLeaveParams({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.document,
  });

  @override
  List<Object?> get props => [
    leaveTypeId, startDate, endDate,
    notes, document,
  ];
}