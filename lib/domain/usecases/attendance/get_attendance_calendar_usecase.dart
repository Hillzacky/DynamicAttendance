import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class GetAttendanceCalendarUseCase {
  final AttendanceRepository _repository;

  GetAttendanceCalendarUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    GetCalendarParams params,
  ) {
    return _repository.getAttendanceCalendar(
      month: params.month,
      year: params.year,
      userId: params.userId,
      attendanceMode: params.attendanceMode,
    );
  }
}

class GetCalendarParams extends Equatable {
  final int month;
  final int year;
  final String? userId;
  final String? attendanceMode;

  const GetCalendarParams({
    required this.month,
    required this.year,
    this.userId,
    this.attendanceMode,
  });

  @override
  List<Object?> get props => [month, year, userId, attendanceMode];
}