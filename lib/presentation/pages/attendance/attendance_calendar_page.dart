import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_event.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_state.dart';
import 'package:attendance_app/presentation/widgets/attendance/attendance_calendar_widget.dart';
import 'package:attendance_app/presentation/widgets/attendance/attendance_detail_card.dart';
import 'package:attendance_app/presentation/widgets/common/app_loading.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  State<AttendanceCalendarPage> createState() =>
      _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, AttendanceCalendarModel> _calendarData = {};
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  void _loadCalendar() {
    context.read<AttendanceBloc>().add(
      GetAttendanceCalendarEvent(
        month: _focusedDay.month,
        year: _focusedDay.year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('Kalender Absensi'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = null;
              });
              _loadCalendar();
            },
            icon: const Icon(Icons.today_rounded),
          ),
        ],
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceCalendarLoaded) {
            setState(() {
              _calendarData = (state.data['calendar']
                      as Map<String, dynamic>)
                  .map((key, value) => MapEntry(
                        key,
                        AttendanceCalendarModel.fromJson(
                          value as Map<String, dynamic>,
                        ),
                      ));
              _summary = state.data['summary'];
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => _loadCalendar(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Calendar Widget
                AttendanceCalendarWidget(
                  calendarData: _calendarData,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) {
                    setState(() => _selectedDay = day);
                  },
                  onPageChanged: (day) {
                    setState(() {
                      _focusedDay = day;
                      _selectedDay = null;
                    });
                    _loadCalendar();
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Summary Cards
                if (_summary != null) _buildSummaryRow(),

                const SizedBox(height: AppSpacing.lg),

                // Legend
                _buildLegend(),

                const SizedBox(height: AppSpacing.lg),

                // Selected Day Detail
                if (_selectedDay != null) _buildSelectedDayDetail(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: 'Hadir',
            value: '${_summary!['total_present'] ?? 0}',
            color: AppColors.checkIn,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildSummaryCard(
            label: 'Terlambat',
            value: '${_summary!['total_late'] ?? 0}',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildSummaryCard(
            label: 'Tidak Hadir',
            value: '${_summary!['total_absent'] ?? 0}',
            color: AppColors.absent,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildSummaryCard(
            label: 'Izin/Cuti',
            value: '${(_summary!['total_leave'] ?? 0) + (_summary!['total_sick'] ?? 0) + (_summary!['total_permit'] ?? 0)}',
            color: AppColors.leave,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingLG.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodyXS,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final legends = [
      {'color': AppColors.checkIn, 'label': 'Hadir'},
      {'color': AppColors.warning, 'label': 'Terlambat'},
      {'color': AppColors.checkOut, 'label': 'Pulang'},
      {'color': AppColors.leave, 'label': 'Cuti'},
      {'color': AppColors.sick, 'label': 'Sakit'},
      {'color': AppColors.permit, 'label': 'Izin'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Keterangan', style: AppTextStyles.labelLG),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: legends.map((legend) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: legend['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    legend['label'] as String,
                    style: AppTextStyles.bodySM,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetail() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final dayData = _calendarData[dateKey];

    if (dayData == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy_outlined,
              color: AppColors.grey400,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Tidak ada data absensi',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return AttendanceDetailCard(
      dayData: dayData,
      selectedDate: _selectedDay!,
    );
  }
}