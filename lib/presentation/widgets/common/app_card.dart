import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.boxShadow,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: borderRadius ??
            BorderRadius.circular(AppRadius.lg),
        boxShadow: boxShadow ?? AppShadows.sm,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ??
            BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ??
              BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: padding ??
                const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}