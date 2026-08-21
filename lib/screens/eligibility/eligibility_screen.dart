// NOTE: EligibilityScreen is bypassed in the active user flow per configuration.
// Navigation progresses directly from DocumentUploadScreen -> CaseSummaryScreen -> LawyerMatchingScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../models/eligibility_model.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/eligibility_provider.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  double _income = 1800.0;
  int _householdSize = 2;
  bool _isResident = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  void _check() {
    final provider = Provider.of<EligibilityProvider>(context, listen: false);
    provider.evaluateEligibility(
      monthlyIncome: _income,
      householdSize: _householdSize,
      isResident: _isResident,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligibilityProvider = Provider.of<EligibilityProvider>(context);
    final result = eligibilityProvider.eligibility;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligibility Pre-Screening'),
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
                  'Financial & Residency Screening',
                  style: AppTextStyles.titleLarge(
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Basic criteria pre-screening to match with subsidized legal-aid resources:',
                  style: AppTextStyles.bodyMedium(
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Monthly Household Income Slider
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 200),
                child: Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Monthly Income',
                            style: AppTextStyles.label(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '\$${_income.toInt()}',
                            style: AppTextStyles.titleMedium(
                              AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _income,
                        min: 0,
                        max: 6000,
                        divisions: 60,
                        activeColor: AppColors.primaryLight,
                        onChanged: (val) {
                          setState(() => _income = val);
                          _check();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Household Size Selector
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Household Members',
                        style: AppTextStyles.label(
                          isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _householdSize > 1
                                ? () {
                                    setState(() => _householdSize--);
                                    _check();
                                  }
                                : null,
                          ),
                          Text(
                            '$_householdSize',
                            style: AppTextStyles.titleMedium(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() => _householdSize++);
                              _check();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Local Resident Toggle
              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'State/County Resident',
                      style: AppTextStyles.label(
                        isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    value: _isResident,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => _isResident = val);
                      _check();
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Screening Result Card
              if (eligibilityProvider.state == ProviderState.loading)
                const AppLoader(message: 'Calculating eligibility criteria...')
              else if (result != null)
                AnimatedFadeSlide(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: result.status == EligibilityResultStatus.eligible
                          ? AppColors.routineBg
                          : AppColors.moderateBg,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                        color: result.status == EligibilityResultStatus.eligible
                            ? AppColors.routineBorder
                            : AppColors.moderateBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.status == EligibilityResultStatus.eligible
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.info_outline_rounded,
                              color:
                                  result.status == EligibilityResultStatus.eligible
                                      ? AppColors.routine
                                      : AppColors.moderate,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              result.status == EligibilityResultStatus.eligible
                                  ? 'Preliminary Status: Eligible'
                                  : 'Status: Secondary Staff Review Required',
                              style: AppTextStyles.label(
                                result.status == EligibilityResultStatus.eligible
                                    ? AppColors.routine
                                    : AppColors.moderate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          result.statusExplanation,
                          style: AppTextStyles.bodyMedium(
                            isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.paddingXL),

              AnimatedFadeSlide(
                delay: const Duration(milliseconds: 600),
                child: AppButton(
                  label: 'Proceed to Lawyer Matching',
                  icon: Icons.person_search_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.matching);
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
