import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/disclaimer_banner.dart';

import '../../providers/routing_provider.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routingProvider = Provider.of<RoutingProvider>(context);
    final routing = routingProvider.routing;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUrgent = routing?.isPriorityEscalated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Routing Status'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisclaimerBanner(compact: true),
              const SizedBox(height: AppDimensions.paddingL),
              AnimatedFadeSlide(
                child: Text(
                  'Intake Routing Pipeline',
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Automated triage status tracking for clinic staff queueing:',
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Priority / Routine Routing Banner
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: isUrgent ? AppColors.urgentBg : AppColors.routineBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isUrgent ? AppColors.urgentBorder : AppColors.routineBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isUrgent ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                            color: isUrgent ? AppColors.urgent : AppColors.routine,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isUrgent ? 'Priority Review Flagged' : 'Standard Queue Routing',
                            style: AppTextStyles.label(
                              isUrgent ? AppColors.urgent : AppColors.routine,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Text(
                        routing?.statusDescription ?? 'Routing pipeline active.',
                        style: AppTextStyles.bodyMedium(
                          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Routing Checklist Steps
              Text(
                'Completed Pipeline Milestones',
                style: AppTextStyles.titleMedium(
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              _buildStepItem(context, 'Intake conversation completed', true, 250),
              _buildStepItem(context, 'Situation & key facts collected', true, 300),
              _buildStepItem(context, 'Legal category identified', true, 350),
              _buildStepItem(context, 'Urgency triage assessed', true, 400),
              _buildStepItem(context, 'Structured summary prepared', true, 450),
              _buildStepItem(context, isUrgent ? 'Priority staff escalation alert active' : 'Waiting for staff review', true, 500),

              const SizedBox(height: AppDimensions.paddingXL),

              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 550),
                child: AppButton(
                  label: 'Proceed to Final Intake Review',
                  icon: Icons.assignment_turned_in_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.submission);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String label, bool isDone, int delay) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedFadeSlide(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isDone ? AppColors.routine : AppColors.textSecondaryLight,
              size: 22,
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Text(
              label,
              style: AppTextStyles.bodyMedium(
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
