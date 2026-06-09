import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/app_theme.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:attendance_app/presentation/widgets/common/app_badge.dart';
import 'package:attendance_app/presentation/widgets/common/app_card.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:attendance_app/core/constants/api_constants.dart';

class AttendanceDetailCard extends StatelessWidget {
  final AttendanceCalendarModel dayData;
  final DateTime selectedDate;

  const AttendanceDetailCard({
    super.key,
    required this.dayData,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(selectedDate),
                style: AppTextStyles.headingSM,
              ),
              if (dayData.leave != null)
                AppBadge.fromLeaveStatus(dayData.leave!.status),
            ],
          ),

          const Divider(height: AppSpacing.xl),

          // Check In
          _buildAttendanceRow(
            type: 'check_in',
            detail: dayData.checkIn,
          ),

          const SizedBox(height: AppSpacing.md),

          // Check Out
          _buildAttendanceRow(
            type: 'check_out',
            detail: dayData.checkOut,
          ),

          // Leave Info
          if (dayData.leave != null) ...[
            const Divider(height: AppSpacing.xl),
            _buildLeaveInfo(dayData.leave!),
          ],

          // Work Duration
          if (dayData.checkIn != null && dayData.checkOut != null) ...[
            const Divider(height: AppSpacing.xl),
            _buildWorkDuration(),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceRow({
    required String type,
    required AttendanceDetailModel? detail,
  }) {
    final isCheckIn = type == 'check_in';
    final label = isCheckIn ? 'Masuk' : 'Keluar';
    final icon = isCheckIn
        ? Icons.login_rounded
        : Icons.logout_rounded;
    final color = isCheckIn ? AppColors.checkIn : AppColors.checkOut;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelLG),
              const SizedBox(height: AppSpacing.xs),
              if (detail != null) ...[
                Text(
                  detail.time,
                  style: AppTextStyles.headingSM.copyWith(
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppBadge.fromAttendanceStatus(detail.status),
              ] else ...[
                Text(
                  'Belum ${isCheckIn ? 'masuk' : 'keluar'}',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Photo
        if (detail?.photoUrl != null)
          GestureDetector(
            onTap: () => _showPhotoDialog(detail!.photoUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: CachedNetworkImage(
                imageUrl:
                    '${ApiConstants.uploadsUrl}/${detail!.photoUrl}',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.grey100,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.grey400,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.grey100,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.grey400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaveInfo(LeaveCalendarModel leave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.leave.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: AppColors.leave,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.leaveTypeName,
                    style: AppTextStyles.labelLG,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${leave.startDate} s/d ${leave.endDate} (${leave.totalDays} hari)',
                    style: AppTextStyles.bodySM,
                  ),
                  if (leave.notes != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      leave.notes!,
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.grey500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkDuration() {
    if (dayData.checkIn == null || dayData.checkOut == null) {
      return const SizedBox.shrink();
    }

    final checkInTime = DateFormat('HH:mm:ss').parse(dayData.checkIn!.time);
    final checkOutTime = DateFormat('HH:mm:ss').parse(dayData.checkOut!.time);
    final duration = checkOutTime.difference(checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.timer_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durasi Kerja',
              style: AppTextStyles.labelLG,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${hours}j ${minutes}m',
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPhotoDialog(String photoUrl) {
    // Show photo in dialog
  }
}