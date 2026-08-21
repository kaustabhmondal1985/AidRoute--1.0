// NOTE: TriageScreen is bypassed in the active user flow per configuration.
// Navigation progresses directly from ConversationScreen -> DocumentUploadScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_status_badge.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../providers/routing_provider.dart';
import '../../providers/triage_provider.dart';

class TriageScreen extends StatelessWidget {
  const TriageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final triageProvider = Provider.of<TriageProvider>(context);
    final category = triageProvider.category;
    final urgency = triageProvider.urgency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUrgent = urgency?.level == UrgencyLevel.urgent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake & Urgency Triage'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mandatory Safety Banner
              const DisclaimerBanner(compact: true),
              const SizedBox(height: AppDimensions.paddingL),

              // Category Classification Card
              AnimatedFadeSlide(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                      Row(
                        children: [
                          const Icon(Icons.category_outlined,
                              color: AppColors.primaryLight, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Likely Intake Category',
                            style: AppTextStyles.label(
                              isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const Spacer(),
                          if (category != null)
                            Chip(
                              label: Text(
                                '${(category.confidenceScore * 100).toInt()}% Match',
                                style: AppTextStyles.caption(AppColors.primaryLight),
                              ),
                              backgroundColor: AppColors.primaryContainer,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Text(
                        category?.title ?? 'General Legal Intake',
                        style: AppTextStyles.titleLarge(
                          isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Text(
                        category?.description ??
                            'Civil intake classification based on submitted context.',
                        style: AppTextStyles.bodyMedium(
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Urgency Level Header & Badge
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isUrgent
                          ? AppColors.urgentBorder
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isUrgent ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assessed Urgency',
                            style: AppTextStyles.titleMedium(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (urgency != null)
                            AppStatusBadge(level: urgency.level),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        urgency?.description ??
                            'Intake processed through triage classification rules.',
                        style: AppTextStyles.bodyMedium(
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingXL),

              // "WHY WAS THIS FLAGGED?" Panel (Key requirement Section 6.6)
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  'Why Was This Case Flagged?',
                  style: AppTextStyles.titleMedium(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Breakdown mapping your reported facts directly to urgency factors:',
                  style: AppTextStyles.caption(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              if (urgency != null && urgency.factors.isNotEmpty)
                ...urgency.factors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final factor = entry.value;

                  return AnimatedFadeSlide(
                    delay: Duration(milliseconds: 350 + (index * 100)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: AppColors.primaryLight, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    factor.urgencyFactor,
                                    style: AppTextStyles.label(
                                      isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User Fact: ${factor.userProvidedFact}',
                                    style: AppTextStyles.bodyMedium(
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Impact: ${factor.impactExplanation}',
                                    style: AppTextStyles.caption(
                                      AppColors.primaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: AppDimensions.paddingL),

              // Navigation Actions
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 550),
                child: AppButton(
                  label: 'Upload Supporting Documents',
                  icon: Icons.upload_file_rounded,
                  onPressed: () {
                    final routingProvider =
                        Provider.of<RoutingProvider>(context, listen: false);
                    routingProvider.initializeRouting(
                      isUrgent: isUrgent,
                      categoryTitle: category?.title ?? 'General Intake',
                    );
                    Navigator.pushNamed(context, RouteConstants.documents);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 575),
                child: AppButton(
                  label: 'Review Case Summary',
                  isSecondary: true,
                  icon: Icons.description_outlined,
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.caseSummary);
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 600),
                child: AppButton(
                  label: 'Skip to Eligibility Pre-Screening',
                  isSecondary: true,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.eligibility);
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
