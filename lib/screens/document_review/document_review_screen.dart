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
import '../../providers/document_provider.dart';

class DocumentReviewScreen extends StatelessWidget {
  const DocumentReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);
    final dates = docProvider.allExtractedDates;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Timeline Review'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisclaimerBanner(compact: true),
              const SizedBox(height: AppDimensions.paddingL),
              AnimatedFadeSlide(
                child: Text(
                  'Extracted Document Timeline',
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'The following key dates were identified from your uploaded documents to assist legal-aid staff during triage:',
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Expanded(
                child: dates.isEmpty
                    ? Center(
                        child: Text(
                          'No extracted dates found. Proceed to next step.',
                          style: AppTextStyles.bodyMedium(
                            isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final item = dates[index];
                          final formattedDate =
                              DateFormat('EEEE, MMM d, yyyy').format(item.date);

                          return AnimatedFadeSlide(
                            delay: Duration(milliseconds: 150 + (index * 100)),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline Indicator Line
                                  Column(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: AppDimensions.paddingM),

                                  // Date Card Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: AppDimensions.paddingL),
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            AppDimensions.paddingM),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.surfaceDark
                                              : AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM),
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.label,
                                              style: AppTextStyles.label(
                                                AppColors.primaryLight,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formattedDate,
                                              style: AppTextStyles.titleMedium(
                                                isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimaryLight,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Source: ${item.sourceDocumentName}',
                                              style: AppTextStyles.caption(
                                                isDark
                                                    ? AppColors.textSecondaryDark
                                                    : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                            if (item.contextSnippet != null) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                    AppDimensions.paddingS),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? AppColors.backgroundDark
                                                      : AppColors.backgroundLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppDimensions.radiusS),
                                                ),
                                                child: Text(
                                                  '"${item.contextSnippet}"',
                                                  style: AppTextStyles.caption(
                                                    isDark
                                                        ? AppColors.textSecondaryDark
                                                        : AppColors.textSecondaryLight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              AnimatedFadeSlide(
                child: AppButton(
                  label: 'Continue to Eligibility Pre-Screening',
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
