import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendance_app/data/datasources/local/auth_local_datasource.dart';
import 'package:attendance_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:attendance_app/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:attendance_app/data/datasources/remote/leave_remote_datasource.dart';
import 'package:attendance_app/data/repositories/auth_repository_impl.dart';
import 'package:attendance_app/data/repositories/attendance_repository_impl.dart';
import 'package:attendance_app/data/repositories/leave_repository_impl.dart';
import 'package:attendance_app/domain/repositories/auth_repository.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';
import 'package:attendance_app/domain/repositories/leave_repository.dart';
import 'package:attendance_app/domain/usecases/auth/login_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/create_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/create_manual_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendance_calendar_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/create_leave_usecase.dart';
import 'package:attendance_app/domain/usecases/leave/get_leave_calendar_usecase.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/leave/leave_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // =============================================
  // External
  // =============================================
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );

  sl.registerLazySingleton<Dio>(() => DioClient.instance);

  // =============================================
  // Data Sources
  // =============================================
  // Local
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  // Remote
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<LeaveRemoteDataSource>(
    () => LeaveRemoteDataSourceImpl(dio: sl()),
  );

  // =============================================
  // Repositories
  // =============================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<LeaveRepository>(
    () => LeaveRepositoryImpl(remote: sl()),
  );

  // =============================================
  // Use Cases
  // =============================================
  // Auth UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyTokenUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));

  // Attendance UseCases
  sl.registerLazySingleton(() => CreateAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => CreateManualAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceCalendarUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendancesUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceByIdUseCase(sl()));

  // Leave UseCases
  sl.registerLazySingleton(() => CreateLeaveUseCase(sl()));
  sl.registerLazySingleton(() => GetLeavesUseCase(sl()));
  sl.registerLazySingleton(() => GetLeaveByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLeaveStatusUseCase(sl()));
  sl.registerLazySingleton(() => CancelLeaveUseCase(sl()));
  sl.registerLazySingleton(() => GetLeaveCalendarUseCase(sl()));
  sl.registerLazySingleton(() => GetLeaveTypesUseCase(sl()));

  // =============================================
  // BLoC
  // =============================================
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      verifyTokenUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCachedUserUseCase: sl(),
      isLoggedInUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AttendanceBloc(
      createAttendanceUseCase: sl(),
      createManualAttendanceUseCase: sl(),
      getTodayAttendanceUseCase: sl(),
      getAttendanceCalendarUseCase: sl(),
      getAttendanceStatisticsUseCase: sl(),
      getAttendancesUseCase: sl(),
      getAttendanceByIdUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => LeaveBloc(
      createLeaveUseCase: sl(),
      getLeavesUseCase: sl(),
      getLeaveByIdUseCase: sl(),
      updateLeaveStatusUseCase: sl(),
      cancelLeaveUseCase: sl(),
      getLeaveCalendarUseCase: sl(),
      getLeaveTypesUseCase: sl(),
    ),
  );
}