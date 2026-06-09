import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/domain/usecases/leave/create_leave_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/get_leaves_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/get_leave_by_id_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/update_leave_status_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/cancel_leave_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/get_leave_calendar_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/get_leave_types_usecase.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final CreateLeaveUseCase createLeaveUseCase;
  final GetLeavesUseCase getLeavesUseCase;
  final GetLeaveByIdUseCase getLeaveByIdUseCase;
  final UpdateLeaveStatusUseCase updateLeaveStatusUseCase;
  final CancelLeaveUseCase cancelLeaveUseCase;
  final GetLeaveCalendarUseCase getLeaveCalendarUseCase;
  final GetLeaveTypesUseCase getLeaveTypesUseCase;

  LeaveBloc({
    required this.createLeaveUseCase,
    required this.getLeavesUseCase,
    required this.getLeaveByIdUseCase,
    required this.updateLeaveStatusUseCase,
    required this.cancelLeaveUseCase,
    required this.getLeaveCalendarUseCase,
    required this.getLeaveTypesUseCase,
  }) : super(const LeaveInitial()) {
    on<GetLeaveTypesEvent>(_onGetLeaveTypes);
    on<GetLeaveCalendarEvent>(_onGetLeaveCalendar);
    on<CreateLeaveEvent>(_onCreateLeave);
    on<GetLeavesEvent>(_onGetLeaves);
    on<GetLeaveByIdEvent>(_onGetLeaveById);
    on<UpdateLeaveStatusEvent>(_onUpdateLeaveStatus);
    on<CancelLeaveEvent>(_onCancelLeave);
    on<DeleteLeaveEvent>(_onDeleteLeave);
  }

  Future<void> _onGetLeaveTypes(
    GetLeaveTypesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveLoading());
    final result = await getLeaveTypesUseCase();
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (leaveTypes) => emit(LeaveTypesLoaded(leaveTypes: leaveTypes)),
    );
  }

  Future<void> _onGetLeaveCalendar(
    GetLeaveCalendarEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveLoading());
    final result = await getLeaveCalendarUseCase(
      GetLeaveCalendarParams(
        month: event.month,
        year: event.year,
        userId: event.userId,
      ),
    );
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (data) => emit(LeaveCalendarLoaded(
        data: data,
        month: event.month,
        year: event.year,
      )),
    );
  }

  Future<void> _onCreateLeave(
    CreateLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveSubmitting());
    final result = await createLeaveUseCase(
      CreateLeaveParams(
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
        notes: event.notes,
        document: event.document,
      ),
    );
    result.fold(
      (failure) => emit(LeaveFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (leave) => emit(LeaveCreateSuccess(
        leave: leave,
        message: 'Pengajuan cuti berhasil dibuat',
      )),
    );
  }

  Future<void> _onGetLeaves(
    GetLeavesEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveLoading());
    final result = await getLeavesUseCase(
      GetLeavesParams(
        page: event.page,
        limit: event.limit,
        userId: event.userId,
        status: event.status,
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (leaves) => emit(LeaveListLoaded(
        leaves: leaves,
        page: event.page,
        totalPages: 1,
        hasNext: false,
      )),
    );
  }

  Future<void> _onGetLeaveById(
    GetLeaveByIdEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveLoading());
    final result = await getLeaveByIdUseCase(event.id);
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (leave) => emit(LeaveDetailLoaded(leave: leave)),
    );
  }

  Future<void> _onUpdateLeaveStatus(
    UpdateLeaveStatusEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveSubmitting());
    final result = await updateLeaveStatusUseCase(
      UpdateLeaveStatusParams(
        id: event.id,
        status: event.status,
        rejectionReason: event.rejectionReason,
      ),
    );
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (leave) => emit(LeaveUpdateSuccess(
        leave: leave,
        message: 'Status cuti berhasil diupdate',
      )),
    );
  }

  Future<void> _onCancelLeave(
    CancelLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveSubmitting());
    final result = await cancelLeaveUseCase(event.id);
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (_) => emit(const LeaveCancelSuccess()),
    );
  }

  Future<void> _onDeleteLeave(
    DeleteLeaveEvent event,
    Emitter<LeaveState> emit,
  ) async {
    emit(const LeaveSubmitting());
    final result = await getLeaveTypesUseCase();
    result.fold(
      (failure) => emit(LeaveFailure(message: failure.message)),
      (_) => emit(const LeaveDeleteSuccess()),
    );
  }
}