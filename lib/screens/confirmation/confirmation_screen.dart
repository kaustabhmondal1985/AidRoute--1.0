import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../providers/submission_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final submissionProvider = Provider.of<SubmissionProvider>(context);
    final result = submissionProvider.result;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUrgent = result?.isUrgentEscalated ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingL),

              // Success Icon Animation
              AnimatedScaleIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.urgentBg : AppColors.routineBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUrgent ? AppColors.urgentBorder : AppColors.routineBorder,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isUrgent ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                    color: isUrgent ? AppColors.urgent : AppColors.routine,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Intake Transmitted Successfully',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingS),

              // Tracking Reference Chip
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 300),
                child: Chip(
                  avatar: const Icon(Icons.confirmation_number_outlined, size: 16),
                  label: Text(
                    'Reference ID: ${result?.trackingReferenceId ?? "AR-100234"}',
                    style: AppTextStyles.label(AppColors.primaryLight),
                  ),
                  backgroundColor: AppColors.primaryContainer,
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Urgent Escalation Banner (If applicable)
              if (isUrgent)
                AnimatedFadeSlide(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.urgentBg,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.urgentBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.priority_high_rounded,
                                color: AppColors.urgent),
                            const SizedBox(width: 8),
                            Text(
                              'Priority Review Status Active',
                              style: AppTextStyles.label(AppColors.urgent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your intake contains details identified as time-sensitive. Your case has been flagged for priority staff review.',
                          style: AppTextStyles.bodyMedium(AppColors.textPrimaryLight),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.paddingL),

              // Mandatory Safety Banner
              const DisclaimerBanner(compact: true),

              const SizedBox(height: AppDimensions.paddingL),

              // Next Steps Checklist
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Steps',
                      style: AppTextStyles.titleMedium(
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      '1. Legal-aid clinic staff will review your structured intake details.',
                      style: AppTextStyles.bodyMedium(
                        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2. If additional information is needed, staff will contact you via phone/email.',
                      style: AppTextStyles.bodyMedium(
                        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3. Submitted timestamp: ${result != null ? DateFormat('MMM d, yyyy h:mm a').format(result.submissionTimestamp) : "Just now"}',
                      style: AppTextStyles.caption(AppColors.primaryLight),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // Action Buttons
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 500),
                child: AppButton(
                  label: 'Return to Home',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteConstants.home,
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
