import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_event.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_state.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:attendance_app/presentation/bloc/auth/auth_state.dart';
import 'package:attendance_app/presentation/widgets/common/app_card.dart';
import 'package:attendance_app/presentation/widgets/common/app_loading.dart';
import 'package:attendance_app/presentation/widgets/common/app_badge.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AttendanceBloc>().add(
      const GetTodayAttendanceEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildDateCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTodayAttendance(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAttendanceSummary(),
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is AuthAuthenticated
                      ? state.user
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.white.withOpacity(0.2),
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(
                                    '${ApiConstants.uploadsUrl}/${user!.avatarUrl}',
                                  )
                                : null,
                            child: user?.avatarUrl == null
                                ? Text(
                                    user?.fullname
                                            .substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: AppTextStyles.headingMD.copyWith(
                                      color: AppColors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat ${_getGreeting()}!',
                                  style: AppTextStyles.bodyMD.copyWith(
                                    color: AppColors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  user?.fullname ?? 'Karyawan',
                                  style: AppTextStyles.headingMD.copyWith(
                                    color: AppColors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/notifications'),
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (user?.departmentName != null ||
                          user?.positionName != null)
                        Text(
                          '${user?.positionName ?? ''} • ${user?.departmentName ?? ''}',
                          style: AppTextStyles.bodySM.copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(now),
                  style: AppTextStyles.headingLG.copyWith(
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat('MMM', 'id_ID').format(now),
                  style: AppTextStyles.labelSM.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE', 'id_ID').format(now),
                  style: AppTextStyles.headingSM,
                ),
                Text(
                  DateFormat('dd MMMM yyyy', 'id_ID').format(now),
                  style: AppTextStyles.bodyMD,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    DateFormat('HH:mm:ss').format(DateTime.now()),
                    style: AppTextStyles.headingSM.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  );
                },
              ),
              Text(
                'WIB',
                style: AppTextStyles.bodySM,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAttendance() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceLoading) {
          return const AppLoadingCard(height: 160);
        }

        if (state is TodayAttendanceLoaded) {
          final data = state.data;
          return AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Absensi Hari Ini',
                      style: AppTextStyles.headingSM,
                    ),
                    if (data.shift != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          data.shift!.name,
                          style: AppTextStyles.labelSM.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceItem(
                        label: 'Masuk',
                        time: data.checkIn != null
                            ? DateFormat('HH:mm').format(
                                data.checkIn!.attendanceTime)
                            : '--:--',
                        icon: Icons.login_rounded,
                        color: AppColors.checkIn,
                        status: data.checkIn?.status,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppColors.grey200,
                    ),
                    Expanded(
                      child: _buildAttendanceItem(
                        label: 'Keluar',
                        time: data.checkOut != null
                            ? DateFormat('HH:mm').format(
                                data.checkOut!.attendanceTime)
                            : '--:--',
                        icon: Icons.logout_rounded,
                        color: AppColors.checkOut,
                        status: data.checkOut?.status,
                      ),
                    ),
                  ],
                ),
                if (data.workDuration != null) ...[
                  const Divider(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Durasi Kerja: ${data.workDuration!.formatted}',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                // Action Buttons
                Row(
                  children: [
                    if (data.canCheckIn)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/attendance/create'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.checkIn,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text('Absen Masuk'),
                        ),
                      ),
                    if (data.canCheckIn && data.canCheckOut)
                      const SizedBox(width: AppSpacing.sm),
                    if (data.canCheckOut)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/attendance/create',
                            extra: {'type': 'check_out'},
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.checkOut,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Absen Keluar'),
                        ),
                      ),
                    if (!data.canCheckIn && !data.canCheckOut)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Absensi Selesai',
                                style: AppTextStyles.labelLG.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAttendanceItem({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
    String? status,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          time,
          style: AppTextStyles.headingMD.copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySM),
        if (status != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppBadge.fromAttendanceStatus(status),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'label': 'Absensi',
        'icon': Icons.fingerprint_rounded,
        'color': AppColors.primary,
        'route': '/attendance/create',
      },
      {
        'label': 'Manual',
        'icon': Icons.edit_calendar_rounded,
        'color': AppColors.secondary,
        'route': '/attendance/manual',
      },
      {
        'label': 'Cuti',
        'icon': Icons.event_busy_rounded,
        'color': AppColors.warning,
        'route': '/leave/create',
      },
      {
        'label': 'Riwayat',
        'icon': Icons.history_rounded,
        'color': AppColors.info,
        'route': '/attendance/history',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTextStyles.headingSM),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return GestureDetector(
              onTap: () => context.push(action['route'] as String),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    action['label'] as String,
                    style: AppTextStyles.labelMD,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ringkasan Bulan Ini', style: AppTextStyles.headingSM),
            TextButton(
              onPressed: () => context.push('/attendance/calendar'),
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceStatisticsLoaded) {
              final summary = state.data['summary'];
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
                children: [
                  _buildSummaryItem(
                    label: 'Hadir',
                    value: '${summary['total_present'] ?? 0}',
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  _buildSummaryItem(
                    label: 'Terlambat',
                    value: '${summary['total_late'] ?? 0}',
                    color: AppColors.warning,
                    icon: Icons.watch_later_outlined,
                  ),
                  _buildSummaryItem(
                    label: 'Tidak Hadir',
                    value: '${summary['total_absent'] ?? 0}',
                    color: AppColors.error,
                    icon: Icons.cancel_outlined,
                  ),
                  _buildSummaryItem(
                    label: 'Cuti',
                    value: '${summary['total_leave'] ?? 0}',
                    color: AppColors.leave,
                    icon: Icons.event_busy_outlined,
                  ),
                  _buildSummaryItem(
                    label: 'Sakit',
                    value: '${summary['total_sick'] ?? 0}',
                    color: AppColors.sick,
                    icon: Icons.local_hospital_outlined,
                  ),
                  _buildSummaryItem(
                    label: 'Kehadiran',
                    value: '${summary['attendance_rate'] ?? 0}%',
                    color: AppColors.primary,
                    icon: Icons.pie_chart_outline_rounded,
                  ),
                ],
              );
            }
            return const AppLoadingCard(height: 160);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingMD.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodyXS,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}