import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance_app/core/errors/failures.dart';
import 'package:attendance_app/domain/repositories/leave_repository.dart';

class GetLeaveCalendarUseCase {
  final LeaveRepository _repository;

  GetLeaveCalendarUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    GetLeaveCalendarParams params,
  ) {
    return _repository.getLeaveCalendar(
      month: params.month,
      year: params.year,
      userId: params.userId,
    );
  }
}

class GetLeaveCalendarParams extends Equatable {
  final int month;
  final int year;
  final String? userId;

  const GetLeaveCalendarParams({
    required this.month,
    required this.year,
    this.userId,
  });

  @override
  List<Object?> get props => [month, year, userId];
}