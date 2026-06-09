import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class GetTodayAttendanceEvent extends AttendanceEvent {
  const GetTodayAttendanceEvent();
}

class GetAttendanceCalendarEvent extends AttendanceEvent {
  final int month;
  final int year;
  final String? userId;
  final String? attendanceMode;

  const GetAttendanceCalendarEvent({
    required this.month,
    required this.year,
    this.userId,
    this.attendanceMode,
  });

  @override
  List<Object?> get props => [month, year, userId, attendanceMode];
}

class CreateAttendanceEvent extends AttendanceEvent {
  final String locationId;
  final String shiftId;
  final String type;
  final double employeeLatitude;
  final double employeeLongitude;
  final File? photo;
  final String? notes;
  final String? deviceId;
  final String? deviceName;

  const CreateAttendanceEvent({
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

class CreateManualAttendanceEvent extends AttendanceEvent {
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

  const CreateManualAttendanceEvent({
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

class GetAttendancesEvent extends AttendanceEvent {
  final int page;
  final int limit;
  final String? userId;
  final String? type;
  final String? status;
  final String? attendanceMode;
  final String? startDate;
  final String? endDate;

  const GetAttendancesEvent({
    this.page = 1,
    this.limit = 10,
    this.userId,
    this.type,
    this.status,
    this.attendanceMode,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    page, limit, userId, type,
    status, attendanceMode,
    startDate, endDate,
  ];
}

class GetAttendanceByIdEvent extends AttendanceEvent {
  final String id;

  const GetAttendanceByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetAttendanceStatisticsEvent extends AttendanceEvent {
  final int month;
  final int year;
  final String? userId;

  const GetAttendanceStatisticsEvent({
    required this.month,
    required this.year,
    this.userId,
  });

  @override
  List<Object?> get props => [month, year, userId];
}