import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/data/models/attendance_model.dart';

class AttendanceCalendarWidget extends StatefulWidget {
  final Map<String, AttendanceCalendarModel> calendarData;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  const AttendanceCalendarWidget({
    super.key,
    required this.calendarData,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.focusedDay,
    this.selectedDay,
  });

  @override
  State<AttendanceCalendarWidget> createState() =>
      _AttendanceCalendarWidgetState();
}

class _AttendanceCalendarWidgetState extends State<AttendanceCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.md,
      ),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) =>
            isSameDay(widget.selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          widget.onDaySelected(selectedDay);
        },
        onPageChanged: widget.onPageChanged,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Bulan',
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: AppTextStyles.headingSM,
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.grey700,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.grey700,
          ),
          headerPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.labelMD.copyWith(
            color: AppColors.grey500,
          ),
          weekendStyle: AppTextStyles.labelMD.copyWith(
            color: AppColors.error,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          outsideTextStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.grey300,
          ),
          defaultTextStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.grey900,
          ),
          weekendTextStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.error,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextStyles.bodyMD.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
          markerDecoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          markersMaxCount: 2,
          markerSize: 6,
          markerMargin: const EdgeInsets.only(top: 1),
          cellMargin: const EdgeInsets.all(4),
          cellPadding: EdgeInsets.zero,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final dateKey =
                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final dayData = widget.calendarData[dateKey];

            if (dayData == null) return const SizedBox.shrink();

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dayData.checkIn != null)
                    _buildDot(_getStatusColor(dayData.checkIn!.status)),
                  if (dayData.checkOut != null) ...[
                    const SizedBox(width: 2),
                    _buildDot(AppColors.checkOut),
                  ],
                  if (dayData.leave != null) ...[
                    const SizedBox(width: 2),
                    _buildDot(_getLeaveColor(dayData.leave!.leaveTypeCode)),
                  ],
                ],
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final dateKey =
                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final dayData = widget.calendarData[dateKey];

            if (dayData == null) return null;

            return Stack(
              alignment: Alignment.center,
              children: [
                if (dayData.leave != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getLeaveColor(dayData.leave!.leaveTypeCode)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '${day.day}',
                  style: AppTextStyles.bodyMD.copyWith(
                    color: day.weekday == DateTime.sunday ||
                            day.weekday == DateTime.saturday
                        ? AppColors.error
                        : AppColors.grey900,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.checkIn;
      case 'late':
        return AppColors.warning;
      case 'early_leave':
        return AppColors.info;
      case 'absent':
        return AppColors.absent;
      default:
        return AppColors.grey400;
    }
  }

  Color _getLeaveColor(String leaveTypeCode) {
    switch (leaveTypeCode) {
      case 'ANNUAL_LEAVE':
        return AppColors.leave;
      case 'SICK_LEAVE':
        return AppColors.sick;
      case 'MATERNITY_LEAVE':
      case 'PATERNITY_LEAVE':
        return AppColors.permit;
      default:
        return AppColors.secondary;
    }
  }
}