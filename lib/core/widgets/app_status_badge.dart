import 'package:flutter/material.dart';

import '../animations/micro_interactions.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

enum UrgencyLevel { urgent, moderate, routine }

class AppStatusBadge extends StatelessWidget {
  final UrgencyLevel level;
  final String? customLabel;

  const AppStatusBadge({
    super.key,
    required this.level,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;

    switch (level) {
      case UrgencyLevel.urgent:
        bg = AppColors.urgentBg;
        border = AppColors.urgentBorder;
        text = AppColors.urgent;
        icon = Icons.error_outline;
        label = customLabel ?? 'Urgent Priority';
        break;
      case UrgencyLevel.moderate:
        bg = AppColors.moderateBg;
        border = AppColors.moderateBorder;
        text = AppColors.moderate;
        icon = Icons.warning_amber_outlined;
        label = customLabel ?? 'Moderate Priority';
        break;
      case UrgencyLevel.routine:
        bg = AppColors.routineBg;
        border = AppColors.routineBorder;
        text = AppColors.routine;
        icon = Icons.check_circle_outline;
        label = customLabel ?? 'Routine Review';
        break;
    }

    final isUrgent = level == UrgencyLevel.urgent;

    return AnimatedPulseBadge(
      isUrgent: isUrgent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: text, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.label(text),
            ),
          ],
        ),
      ),
    );
  }
}
