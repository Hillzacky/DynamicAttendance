import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_event.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_state.dart';
import 'package:attendance_app/presentation/widgets/common/app_button.dart';
import 'package:attendance_app/presentation/widgets/common/app_text_field.dart';
import 'package:attendance_app/presentation/widgets/common/app_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthLoginEvent(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        devicePlatform: Theme.of(context).platform.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          context.go('/home');
        } else if (state is AuthLoginFailure) {
          AppSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.giant),

                  // Logo & Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Selamat Datang',
                          style: AppTextStyles.headingXL,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Masuk ke akun Anda',
                          style: AppTextStyles.bodyMD,
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxxl),

                  // Username Field
                  AppTextField(
                    controller: _usernameController,
                    label: 'Username / Email',
                    hint: 'Masukkan username atau email',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username wajib diisi';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSpacing.lg),

                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Masukkan password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey400,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                  const SizedBox(height: AppSpacing.md),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Ingat Saya',
                            style: AppTextStyles.bodyMD,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Lupa Password?',
                          style: AppTextStyles.labelLG.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Masuk',
                        onPressed: _onLogin,
                        isLoading: state is AuthLoading,
                        icon: Icons.login_rounded,
                      );
                    },
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                  const SizedBox(height: AppSpacing.xxl),

                  Center(
                    child: Text(
                      'v1.0.0 © 2026 Attendance App',
                      style: AppTextStyles.bodyXS.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}