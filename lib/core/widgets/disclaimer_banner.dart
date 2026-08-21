import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class DisclaimerBanner extends StatelessWidget {
  final bool compact;

  const DisclaimerBanner({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = compact
        ? AppTextStyles.caption(
            isDark ? AppTextStyles.caption(AppColors.textSecondaryDark).color! : AppColors.textSecondaryLight,
          )
        : AppTextStyles.bodyMedium(
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );

    return Container(
      padding: EdgeInsets.all(compact ? AppDimensions.paddingS : AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.primaryLight,
            size: compact ? 18 : 22,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              AppConstants.disclaimerText,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
