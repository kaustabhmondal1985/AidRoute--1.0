import 'package:flutter/material.dart';

import '../animations/micro_interactions.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSecondary
        ? (isDark ? AppColors.surfaceDark : AppColors.borderLight)
        : (isDark ? AppColors.primaryLight : AppColors.primary);

    final fgColor = isSecondary
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
        : Colors.white;

    return AnimatedPressScale(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: onPressed == null ? bgColor.withValues(alpha: 0.5) : bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: fgColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.label(fgColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
