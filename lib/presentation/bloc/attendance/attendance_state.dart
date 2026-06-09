import 'package:equatable/equatable.dart';
import 'package:attendance_app/data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceSubmitting extends AttendanceState {
  const AttendanceSubmitting();
}

class TodayAttendanceLoaded extends AttendanceState {
  final TodayAttendanceModel data;

  const TodayAttendanceLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class AttendanceCalendarLoaded extends AttendanceState {
  final Map<String, dynamic> data;
  final int month;
  final int year;

  const AttendanceCalendarLoaded({
    required this.data,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [data, month, year];
}

class AttendanceListLoaded extends AttendanceState {
  final List<AttendanceModel> attendances;
  final int page;
  final int totalPages;
  final bool hasNext;

  const AttendanceListLoaded({
    required this.attendances,
    required this.page,
    required this.totalPages,
    required this.hasNext,
  });

  @override
  List<Object?> get props => [attendances, page, totalPages, hasNext];
}

class AttendanceDetailLoaded extends AttendanceState {
  final AttendanceModel attendance;

  const AttendanceDetailLoaded({required this.attendance});

  @override
  List<Object?> get props => [attendance];
}

class AttendanceStatisticsLoaded extends AttendanceState {
  final Map<String, dynamic> data;

  const AttendanceStatisticsLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class AttendanceCreateSuccess extends AttendanceState {
  final AttendanceModel attendance;
  final String message;

  const AttendanceCreateSuccess({
    required this.attendance,
    required this.message,
  });

  @override
  List<Object?> get props => [attendance, message];
}

class AttendanceFailure extends AttendanceState {
  final String message;
  final int? statusCode;

  const AttendanceFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}