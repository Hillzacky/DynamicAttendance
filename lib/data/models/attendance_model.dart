import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final String id;
  final String userId;
  final String? employeeName;
  final String? nip;
  final String clientId;
  final String? clientName;
  final String? departmentName;
  final String? positionName;
  final String? locationId;
  final String? locationName;
  final String? locationAddress;
  final String? shiftId;
  final String? shiftName;
  final String? checkInTime;
  final String? checkOutTime;
  final DateTime attendanceDate;
  final String type;
  final String attendanceMode;
  final DateTime attendanceTime;
  final String? photoUrl;
  final double? employeeLatitude;
  final double? employeeLongitude;
  final double? officeLatitude;
  final double? officeLongitude;
  final double? distanceMeter;
  final int? radiusMeter;
  final bool isWithinRadius;
  final String status;
  final DateTime? manualDate;
  final String? manualTime;
  final String? manualReason;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final String? deviceId;
  final String? deviceName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    required this.userId,
    this.employeeName,
    this.nip,
    required this.clientId,
    this.clientName,
    this.departmentName,
    this.positionName,
    this.locationId,
    this.locationName,
    this.locationAddress,
    this.shiftId,
    this.shiftName,
    this.checkInTime,
    this.checkOutTime,
    required this.attendanceDate,
    required this.type,
    required this.attendanceMode,
    required this.attendanceTime,
    this.photoUrl,
    this.employeeLatitude,
    this.employeeLongitude,
    this.officeLatitude,
    this.officeLongitude,
    this.distanceMeter,
    this.radiusMeter,
    this.isWithinRadius = false,
    required this.status,
    this.manualDate,
    this.manualTime,
    this.manualReason,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    this.deviceId,
    this.deviceName,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      employeeName: json['employee_name'],
      nip: json['nip'],
      clientId: json['client_id'] ?? '',
      clientName: json['client_name'],
      departmentName: json['department_name'],
      positionName: json['position_name'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      locationAddress: json['location_address'],
      shiftId: json['shift_id'],
      shiftName: json['shift_name'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      attendanceDate: DateTime.parse(json['attendance_date']),
      type: json['type'] ?? '',
      attendanceMode: json['attendance_mode'] ?? 'current',
      attendanceTime: DateTime.parse(json['attendance_time']),
      photoUrl: json['photo_url'],
      employeeLatitude: json['employee_latitude']?.toDouble(),
      employeeLongitude: json['employee_longitude']?.toDouble(),
      officeLatitude: json['office_latitude']?.toDouble(),
      officeLongitude: json['office_longitude']?.toDouble(),
      distanceMeter: json['distance_meter']?.toDouble(),
      radiusMeter: json['radius_meter'],
      isWithinRadius: json['is_within_radius'] ?? false,
      status: json['status'] ?? 'present',
      manualDate: json['manual_date'] != null
          ? DateTime.parse(json['manual_date'])
          : null,
      manualTime: json['manual_time'],
      manualReason: json['manual_reason'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      notes: json['notes'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_name': employeeName,
      'nip': nip,
      'client_id': clientId,
      'client_name': clientName,
      'department_name': departmentName,
      'position_name': positionName,
      'location_id': locationId,
      'location_name': locationName,
      'location_address': locationAddress,
      'shift_id': shiftId,
      'shift_name': shiftName,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'attendance_date': attendanceDate.toIso8601String(),
      'type': type,
      'attendance_mode': attendanceMode,
      'attendance_time': attendanceTime.toIso8601String(),
      'photo_url': photoUrl,
      'employee_latitude': employeeLatitude,
      'employee_longitude': employeeLongitude,
      'office_latitude': officeLatitude,
      'office_longitude': officeLongitude,
      'distance_meter': distanceMeter,
      'radius_meter': radiusMeter,
      'is_within_radius': isWithinRadius,
      'status': status,
      'manual_date': manualDate?.toIso8601String(),
      'manual_time': manualTime,
      'manual_reason': manualReason,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'notes': notes,
      'device_id': deviceId,
      'device_name': deviceName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? employeeName,
    String? nip,
    String? clientId,
    String? clientName,
    String? departmentName,
    String? positionName,
    String? locationId,
    String? locationName,
    String? locationAddress,
    String? shiftId,
    String? shiftName,
    String? checkInTime,
    String? checkOutTime,
    DateTime? attendanceDate,
    String? type,
    String? attendanceMode,
    DateTime? attendanceTime,
    String? photoUrl,
    double? employeeLatitude,
    double? employeeLongitude,
    double? officeLatitude,
    double? officeLongitude,
    double? distanceMeter,
    int? radiusMeter,
    bool? isWithinRadius,
    String? status,
    DateTime? manualDate,
    String? manualTime,
    String? manualReason,
    String? approvedBy,
    DateTime? approvedAt,
    String? notes,
    String? deviceId,
    String? deviceName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      nip: nip ?? this.nip,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      departmentName: departmentName ?? this.departmentName,
      positionName: positionName ?? this.positionName,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      shiftId: shiftId ?? this.shiftId,
      shiftName: shiftName ?? this.shiftName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      type: type ?? this.type,
      attendanceMode: attendanceMode ?? this.attendanceMode,
      attendanceTime: attendanceTime ?? this.attendanceTime,
      photoUrl: photoUrl ?? this.photoUrl,
      employeeLatitude: employeeLatitude ?? this.employeeLatitude,
      employeeLongitude: employeeLongitude ?? this.employeeLongitude,
      officeLatitude: officeLatitude ?? this.officeLatitude,
      officeLongitude: officeLongitude ?? this.officeLongitude,
      distanceMeter: distanceMeter ?? this.distanceMeter,
      radiusMeter: radiusMeter ?? this.radiusMeter,
      isWithinRadius: isWithinRadius ?? this.isWithinRadius,
      status: status ?? this.status,
      manualDate: manualDate ?? this.manualDate,
      manualTime: manualTime ?? this.manualTime,
      manualReason: manualReason ?? this.manualReason,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, employeeName, nip,
    clientId, clientName, departmentName,
    positionName, locationId, locationName,
    locationAddress, shiftId, shiftName,
    checkInTime, checkOutTime, attendanceDate,
    type, attendanceMode, attendanceTime,
    photoUrl, employeeLatitude, employeeLongitude,
    officeLatitude, officeLongitude, distanceMeter,
    radiusMeter, isWithinRadius, status,
    manualDate, manualTime, manualReason,
    approvedBy, approvedAt, notes,
    deviceId, deviceName, createdAt, updatedAt,
  ];
}

// =============================================
// Attendance Calendar Model
// =============================================
class AttendanceCalendarModel extends Equatable {
  final String date;
  final AttendanceDetailModel? checkIn;
  final AttendanceDetailModel? checkOut;
  final String? status;
  final bool hasAttendance;
  final LeaveCalendarModel? leave;

  const AttendanceCalendarModel({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.status,
    this.hasAttendance = false,
    this.leave,
  });

  factory AttendanceCalendarModel.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarModel(
      date: json['date'] ?? '',
      checkIn: json['check_in'] != null
          ? AttendanceDetailModel.fromJson(json['check_in'])
          : null,
      checkOut: json['check_out'] != null
          ? AttendanceDetailModel.fromJson(json['check_out'])
          : null,
      status: json['status'],
      hasAttendance: json['has_attendance'] ?? false,
      leave: json['leave'] != null
          ? LeaveCalendarModel.fromJson(json['leave'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    date, checkIn, checkOut,
    status, hasAttendance, leave,
  ];
}

class AttendanceDetailModel extends Equatable {
  final String id;
  final String time;
  final String status;
  final String? photoUrl;
  final String? notes;
  final double? distanceMeter;
  final bool isWithinRadius;

  const AttendanceDetailModel({
    required this.id,
    required this.time,
    required this.status,
    this.photoUrl,
    this.notes,
    this.distanceMeter,
    this.isWithinRadius = false,
  });

  factory AttendanceDetailModel.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailModel(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      photoUrl: json['photo_url'],
      notes: json['notes'],
      distanceMeter: json['distance_meter']?.toDouble(),
      isWithinRadius: json['is_within_radius'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id, time, status, photoUrl,
    notes, distanceMeter, isWithinRadius,
  ];
}

// =============================================
// Today Attendance Model
// =============================================
class TodayAttendanceModel extends Equatable {
  final String date;
  final AttendanceModel? checkIn;
  final AttendanceModel? checkOut;
  final WorkDurationModel? workDuration;
  final bool canCheckIn;
  final bool canCheckOut;
  final ShiftModel? shift;
  final List<LocationModel> locations;

  const TodayAttendanceModel({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.workDuration,
    required this.canCheckIn,
    required this.canCheckOut,
    this.shift,
    this.locations = const [],
  });

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceModel(
      date: json['date'] ?? '',
      checkIn: json['check_in'] != null
          ? AttendanceModel.fromJson(json['check_in'])
          : null,
      checkOut: json['check_out'] != null
          ? AttendanceModel.fromJson(json['check_out'])
          : null,
      workDuration: json['work_duration'] != null
          ? WorkDurationModel.fromJson(json['work_duration'])
          : null,
      canCheckIn: json['can_check_in'] ?? true,
      canCheckOut: json['can_check_out'] ?? false,
      shift: json['shift'] != null
          ? ShiftModel.fromJson(json['shift'])
          : null,
      locations: json['locations'] != null
          ? List<LocationModel>.from(
              json['locations'].map((x) => LocationModel.fromJson(x)),
            )
          : [],
    );
  }

  @override
  List<Object?> get props => [
    date, checkIn, checkOut, workDuration,
    canCheckIn, canCheckOut, shift, locations,
  ];
}

class WorkDurationModel extends Equatable {
  final int hours;
  final int minutes;
  final String formatted;
  final int totalMinutes;

  const WorkDurationModel({
    required this.hours,
    required this.minutes,
    required this.formatted,
    required this.totalMinutes,
  });

  factory WorkDurationModel.fromJson(Map<String, dynamic> json) {
    return WorkDurationModel(
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      formatted: json['formatted'] ?? '0j 0m',
      totalMinutes: json['total_minutes'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [hours, minutes, formatted, totalMinutes];
}