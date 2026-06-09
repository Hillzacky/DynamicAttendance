import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class CreateManualAttendanceUseCase {
  final AttendanceRepository _repository;

  CreateManualAttendanceUseCase(this._repository);

  Future<Either<Failure, AttendanceModel>> call(
    CreateManualAttendanceParams params,
  ) {
    return _repository.createManualAttendance(
      locationId: params.locationId,
      shiftId: params.shiftId,
      type: params.type,
      manualDate: params.manualDate,
      manualTime: params.manualTime,
      manualReason: params.manualReason,
      photo: params.photo,
      notes: params.notes,
      deviceId: params.deviceId,
      deviceName: params.deviceName,
    );
  }
}

class CreateManualAttendanceParams extends Equatable {
  final String locationId;
  final String shiftId;
  final String type;
  final String manualDate;
  final String manualTime;
  final String manualReason;
  final File? photo;
  final String? notes;
  final String? deviceId;
  final String? deviceName;

  const CreateManualAttendanceParams({
    required this.locationId,
    required this.shiftId,
    required this.type,
    required this.manualDate,
    required this.manualTime,
    required this.manualReason,
    this.photo,
    this.notes,
    this.deviceId,
    this.deviceName,
  });

  @override
  List<Object?> get props => [
    locationId, shiftId, type,
    manualDate, manualTime, manualReason,
    photo, notes, deviceId, deviceName,
  ];
}