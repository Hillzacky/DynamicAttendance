import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/domain/usecases/auth/login_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/logout_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/verify_token_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/get_cached_user_usecase.dart';
import 'package:attendance_app/domain/usecases/auth/is_logged_in_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final VerifyTokenUseCase verifyTokenUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.verifyTokenUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.getCachedUserUseCase,
    required this.isLoggedInUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthVerifyTokenEvent>(_onVerifyToken);
    on<AuthCheckLoginEvent>(_onCheckLogin);
    on<AuthForgotPasswordEvent>(_onForgotPassword);
    on<AuthResetPasswordEvent>(_onResetPassword);
  }

  // =============================================
  // LOGIN
  // =============================================
  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        username: event.username,
        password: event.password,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
        devicePlatform: event.devicePlatform,
      ),
    );

    result.fold(
      (failure) => emit(AuthLoginFailure(
        message: failure.message,
        errors: failure is ValidationFailure ? failure.errors : null,
      )),
      (user) => emit(AuthLoginSuccess(user: user)),
    );
  }

  // =============================================
  // LOGOUT
  // =============================================
  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUseCase();
    emit(const AuthLogoutSuccess());
  }

  // =============================================
  // VERIFY TOKEN
  // =============================================
  Future<void> _onVerifyToken(
    AuthVerifyTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await verifyTokenUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  // =============================================
  // CHECK LOGIN
  // =============================================
  Future<void> _onCheckLogin(
    AuthCheckLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedInResult = await isLoggedInUseCase();

    await isLoggedInResult.fold(
      (failure) async => emit(const AuthUnauthenticated()),
      (isLoggedIn) async {
        if (!isLoggedIn) {
          emit(const AuthUnauthenticated());
          return;
        }

        // Verify token with server
        final verifyResult = await verifyTokenUseCase();
        verifyResult.fold(
          (failure) {
            // Try cached user
            emit(const AuthUnauthenticated());
          },
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
    );
  }

  // =============================================
  // FORGOT PASSWORD
  // =============================================
  Future<void> _onForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await forgotPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(AuthForgotPasswordFailure(
        message: failure.message,
      )),
      (_) => emit(const AuthForgotPasswordSuccess(
        message: 'Jika email terdaftar, instruksi reset password akan dikirim',
      )),
    );
  }

  // =============================================
  // RESET PASSWORD
  // =============================================
  Future<void> _onResetPassword(
    AuthResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        token: event.token,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.fold(
      (failure) => emit(AuthResetPasswordFailure(
        message: failure.message,
      )),
      (_) => emit(const AuthResetPasswordSuccess()),
    );
  }
}