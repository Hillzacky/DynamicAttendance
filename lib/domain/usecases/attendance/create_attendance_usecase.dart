import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class CreateAttendanceUseCase {
  final AttendanceRepository _repository;

  CreateAttendanceUseCase(this._repository);

  Future<Either<Failure, AttendanceModel>> call(
    CreateAttendanceParams params,
  ) {
    return _repository.createAttendance(
      locationId: params.locationId,
      shiftId: params.shiftId,
      type: params.type,
      employeeLatitude: params.employeeLatitude,
      employeeLongitude: params.employeeLongitude,
      photo: params.photo,
      notes: params.notes,
      deviceId: params.deviceId,
      deviceName: params.deviceName,
    );
  }
}

class CreateAttendanceParams extends Equatable {
  final String locationId;
  final String shiftId;
  final String type;
  final double employeeLatitude;
  final double employeeLongitude;
  final File? photo;
  final String? notes;
  final String? deviceId;
  final String? deviceName;

  const CreateAttendanceParams({
    required this.locationId,
    required this.shiftId,
    required this.type,
    required this.employeeLatitude,
    required this.employeeLongitude,
    this.photo,
    this.notes,
    this.deviceId,
    this.deviceName,
  });

  @override
  List<Object?> get props => [
    locationId, shiftId, type,
    employeeLatitude, employeeLongitude,
    photo, notes, deviceId, deviceName,
  ];
}