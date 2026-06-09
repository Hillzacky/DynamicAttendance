import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/app_theme.dart';

enum BadgeVariant {
  success, error, warning, info,
  primary, secondary, neutral,
}

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final bool dot;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors['text'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelSM.copyWith(
              color: colors['text'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (variant) {
      case BadgeVariant.success:
        return {
          'background': AppColors.successLight,
          'text': AppColors.success,
        };
      case BadgeVariant.error:
        return {
          'background': AppColors.errorLight,
          'text': AppColors.error,
        };
      case BadgeVariant.warning:
        return {
          'background': AppColors.warningLight,
          'text': AppColors.warning,
        };
      case BadgeVariant.info:
        return {
          'background': AppColors.infoLight,
          'text': AppColors.info,
        };
      case BadgeVariant.primary:
        return {
          'background': AppColors.primarySurface,
          'text': AppColors.primary,
        };
      case BadgeVariant.secondary:
        return {
          'background': AppColors.secondarySurface,
          'text': AppColors.secondary,
        };
      case BadgeVariant.neutral:
        return {
          'background': AppColors.grey100,
          'text': AppColors.grey600,
        };
    }
  }

  // Helper untuk status absensi
  static AppBadge fromAttendanceStatus(String status) {
    switch (status) {
      case 'present':
        return const AppBadge(
          label: 'Hadir',
          variant: BadgeVariant.success,
          dot: true,
        );
      case 'late':
        return const AppBadge(
          label: 'Terlambat',
          variant: BadgeVariant.warning,
          dot: true,
        );
      case 'early_leave':
        return const AppBadge(
          label: 'Pulang Awal',
          variant: BadgeVariant.info,
          dot: true,
        );
      case 'absent':
        return const AppBadge(
          label: 'Tidak Hadir',
          variant: BadgeVariant.error,
          dot: true,
        );
      case 'pending':
        return const AppBadge(
          label: 'Menunggu',
          variant: BadgeVariant.neutral,
          dot: true,
        );
      case 'approved':
        return const AppBadge(
          label: 'Disetujui',
          variant: BadgeVariant.success,
          dot: true,
        );
      case 'rejected':
        return const AppBadge(
          label: 'Ditolak',
          variant: BadgeVariant.error,
          dot: true,
        );
      default:
        return AppBadge(
          label: status,
          variant: BadgeVariant.neutral,
          dot: true,
        );
    }
  }

  // Helper untuk status cuti
  static AppBadge fromLeaveStatus(String status) {
    switch (status) {
      case 'pending':
        return const AppBadge(
          label: 'Menunggu',
          variant: BadgeVariant.warning,
          dot: true,
        );
      case 'approved':
        return const AppBadge(
          label: 'Disetujui',
          variant: BadgeVariant.success,
          dot: true,
        );
      case 'rejected':
        return const AppBadge(
          label: 'Ditolak',
          variant: BadgeVariant.error,
          dot: true,
        );
      case 'cancelled':
        return const AppBadge(
          label: 'Dibatalkan',
          variant: BadgeVariant.neutral,
          dot: true,
        );
      default:
        return AppBadge(
          label: status,
          variant: BadgeVariant.neutral,
          dot: true,
        );
    }
  }
}