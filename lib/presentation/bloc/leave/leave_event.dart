import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class GetLeaveTypesEvent extends LeaveEvent {
  const GetLeaveTypesEvent();
}

class GetLeaveCalendarEvent extends LeaveEvent {
  final int month;
  final int year;
  final String? userId;

  const GetLeaveCalendarEvent({
    required this.month,
    required this.year,
    this.userId,
  });

  @override
  List<Object?> get props => [month, year, userId];
}

class CreateLeaveEvent extends LeaveEvent {
  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final String? notes;
  final File? document;

  const CreateLeaveEvent({
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

class GetLeavesEvent extends LeaveEvent {
  final int page;
  final int limit;
  final String? userId;
  final String? status;
  final String? leaveTypeId;
  final String? startDate;
  final String? endDate;

  const GetLeavesEvent({
    this.page = 1,
    this.limit = 10,
    this.userId,
    this.status,
    this.leaveTypeId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    page, limit, userId, status,
    leaveTypeId, startDate, endDate,
  ];
}

class GetLeaveByIdEvent extends LeaveEvent {
  final String id;

  const GetLeaveByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateLeaveStatusEvent extends LeaveEvent {
  final String id;
  final String status;
  final String? rejectionReason;

  const UpdateLeaveStatusEvent({
    required this.id,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, status, rejectionReason];
}

class CancelLeaveEvent extends LeaveEvent {
  final String id;

  const CancelLeaveEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteLeaveEvent extends LeaveEvent {
  final String id;

  const DeleteLeaveEvent({required this.id});

  @override
  List<Object?> get props => [id];
}