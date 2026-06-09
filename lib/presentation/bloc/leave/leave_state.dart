import 'package:equatable/equatable.dart';
import 'package:attendance_app/data/models/leave_model.dart';

abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];
}

class LeaveInitial extends LeaveState {
  const LeaveInitial();
}

class LeaveLoading extends LeaveState {
  const LeaveLoading();
}

class LeaveSubmitting extends LeaveState {
  const LeaveSubmitting();
}

class LeaveTypesLoaded extends LeaveState {
  final List<LeaveTypeModel> leaveTypes;

  const LeaveTypesLoaded({required this.leaveTypes});

  @override
  List<Object?> get props => [leaveTypes];
}

class LeaveCalendarLoaded extends LeaveState {
  final Map<String, dynamic> data;
  final int month;
  final int year;

  const LeaveCalendarLoaded({
    required this.data,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [data, month, year];
}

class LeaveListLoaded extends LeaveState {
  final List<LeaveModel> leaves;
  final int page;
  final int totalPages;
  final bool hasNext;

  const LeaveListLoaded({
    required this.leaves,
    required this.page,
    required this.totalPages,
    required this.hasNext,
  });

  @override
  List<Object?> get props => [leaves, page, totalPages, hasNext];
}

class LeaveDetailLoaded extends LeaveState {
  final LeaveModel leave;

  const LeaveDetailLoaded({required this.leave});

  @override
  List<Object?> get props => [leave];
}

class LeaveCreateSuccess extends LeaveState {
  final LeaveModel leave;
  final String message;

  const LeaveCreateSuccess({
    required this.leave,
    required this.message,
  });

  @override
  List<Object?> get props => [leave, message];
}

class LeaveUpdateSuccess extends LeaveState {
  final LeaveModel leave;
  final String message;

  const LeaveUpdateSuccess({
    required this.leave,
    required this.message,
  });

  @override
  List<Object?> get props => [leave, message];
}

class LeaveCancelSuccess extends LeaveState {
  const LeaveCancelSuccess();
}

class LeaveDeleteSuccess extends LeaveState {
  const LeaveDeleteSuccess();
}

class LeaveFailure extends LeaveState {
  final String message;
  final int? statusCode;

  const LeaveFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}