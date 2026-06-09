import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/domain/usecases/attendance/create_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/create_manual_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_today_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendance_calendar_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendance_statistics_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendances_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendance_by_id_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CreateAttendanceUseCase createAttendanceUseCase;
  final CreateManualAttendanceUseCase createManualAttendanceUseCase;
  final GetTodayAttendanceUseCase getTodayAttendanceUseCase;
  final GetAttendanceCalendarUseCase getAttendanceCalendarUseCase;
  final GetAttendanceStatisticsUseCase getAttendanceStatisticsUseCase;
  final GetAttendancesUseCase getAttendancesUseCase;
  final GetAttendanceByIdUseCase getAttendanceByIdUseCase;

  AttendanceBloc({
    required this.createAttendanceUseCase,
    required this.createManualAttendanceUseCase,
    required this.getTodayAttendanceUseCase,
    required this.getAttendanceCalendarUseCase,
    required this.getAttendanceStatisticsUseCase,
    required this.getAttendancesUseCase,
    required this.getAttendanceByIdUseCase,
  }) : super(const AttendanceInitial()) {
    on<GetTodayAttendanceEvent>(_onGetTodayAttendance);
    on<GetAttendanceCalendarEvent>(_onGetAttendanceCalendar);
    on<CreateAttendanceEvent>(_onCreateAttendance);
    on<CreateManualAttendanceEvent>(_onCreateManualAttendance);
    on<GetAttendancesEvent>(_onGetAttendances);
    on<GetAttendanceByIdEvent>(_onGetAttendanceById);
    on<GetAttendanceStatisticsEvent>(_onGetAttendanceStatistics);
  }

  // =============================================
  // GET TODAY ATTENDANCE
  // =============================================
  Future<void> _onGetTodayAttendance(
    GetTodayAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await getTodayAttendanceUseCase();

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (data) => emit(TodayAttendanceLoaded(data: data)),
    );
  }

  // =============================================
  // GET ATTENDANCE CALENDAR
  // =============================================
  Future<void> _onGetAttendanceCalendar(
    GetAttendanceCalendarEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await getAttendanceCalendarUseCase(
      GetCalendarParams(
        month: event.month,
        year: event.year,
        userId: event.userId,
        attendanceMode: event.attendanceMode,
      ),
    );

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (data) => emit(AttendanceCalendarLoaded(
        data: data,
        month: event.month,
        year: event.year,
      )),
    );
  }

  // =============================================
  // CREATE ATTENDANCE
  // =============================================
  Future<void> _onCreateAttendance(
    CreateAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceSubmitting());

    final result = await createAttendanceUseCase(
      CreateAttendanceParams(
        locationId: event.locationId,
        shiftId: event.shiftId,
        type: event.type,
        employeeLatitude: event.employeeLatitude,
        employeeLongitude: event.employeeLongitude,
        photo: event.photo,
        notes: event.notes,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
      ),
    );

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (attendance) => emit(AttendanceCreateSuccess(
        attendance: attendance,
        message: 'Absensi berhasil ditambahkan',
      )),
    );
  }

  // =============================================
  // CREATE MANUAL ATTENDANCE
  // =============================================
  Future<void> _onCreateManualAttendance(
    CreateManualAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceSubmitting());

    final result = await createManualAttendanceUseCase(
      CreateManualAttendanceParams(
        locationId: event.locationId,
        shiftId: event.shiftId,
        type: event.type,
        manualDate: event.manualDate,
        manualTime: event.manualTime,
        manualReason: event.manualReason,
        photo: event.photo,
        notes: event.notes,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
      ),
    );

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (attendance) => emit(AttendanceCreateSuccess(
        attendance: attendance,
        message: 'Absensi manual berhasil ditambahkan',
      )),
    );
  }

  // =============================================
  // GET ATTENDANCES
  // =============================================
  Future<void> _onGetAttendances(
    GetAttendancesEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await getAttendancesUseCase(
      GetAttendancesParams(
        page: event.page,
        limit: event.limit,
        userId: event.userId,
        type: event.type,
        status: event.status,
        attendanceMode: event.attendanceMode,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (attendances) => emit(AttendanceListLoaded(
        attendances: attendances,
        page: event.page,
        totalPages: 1,
        hasNext: false,
      )),
    );
  }

  // =============================================
  // GET ATTENDANCE BY ID
  // =============================================
  Future<void> _onGetAttendanceById(
    GetAttendanceByIdEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await getAttendanceByIdUseCase(event.id);

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (attendance) => emit(AttendanceDetailLoaded(
        attendance: attendance,
      )),
    );
  }

  // =============================================
  // GET ATTENDANCE STATISTICS
  // =============================================
  Future<void> _onGetAttendanceStatistics(
    GetAttendanceStatisticsEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    final result = await getAttendanceStatisticsUseCase(
      GetAttendanceStatisticsParams(
        month: event.month,
        year: event.year,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(AttendanceFailure(
        message: failure.message,
        statusCode: failure.statusCode,
      )),
      (data) => emit(AttendanceStatisticsLoaded(data: data)),
    );
  }
}